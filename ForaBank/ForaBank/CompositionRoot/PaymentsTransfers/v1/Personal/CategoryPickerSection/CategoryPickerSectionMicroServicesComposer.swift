//
//  CategoryPickerSectionMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

final class CategoryPickerSectionMicroServicesComposer<List, ListModel> {
    
#warning("see PaymentFlowMicroServiceComposerNanoServicesComposer")
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = CategoryPickerSectionMicroServicesComposerNanoServices<List, ListModel>
}

extension CategoryPickerSectionMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(getNavigation: getNavigation)
    }
    
    typealias Select = CategoryPickerSectionItem<ServiceCategory, List>
    typealias Navigation = SelectedCategoryNavigation<ListModel>
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias MicroServices = FlowDomain.MicroServices
}

private extension CategoryPickerSectionMicroServicesComposer {
    
    func getNavigation(
        payload: Select,
        notify: @escaping (FlowDomain.Event) -> Void,
        completion: @escaping (SelectedCategoryNavigation<ListModel>) -> Void
    ) {
        switch payload {
        case let .category(category):
            switch category.paymentFlow {
            case .mobile:
                completion(.paymentFlow(.mobile(nanoServices.makeMobile())))
                
            case .qr:
                let qr = nanoServices.makeQR()
                let cancellable = qr.$state
                    .flatMap(notifyPublisher)
                    .sink(receiveValue: notify)
                
                completion(.paymentFlow(.qr(.init(
                    model: qr,
                    cancellable: cancellable
                ))))
                
            case .standard:
                nanoServices.makeStandard(category) {
                    
                    completion(.paymentFlow(.standard($0)))
                }
                
            case .taxAndStateServices:
                completion(.paymentFlow(.taxAndStateServices(nanoServices.makeTax())))
                
            case .transport:
                guard let transport = nanoServices.makeTransport()
                else { return completion(.failure(.transport)) }
                
                completion(.paymentFlow(.transport(transport)))
            }
            
        case let .list(categories):
            completion(.list(nanoServices.makeList(categories)))
        }
    }
    
    private func notifyPublisher(
        result: QRModelWrapperState<QRModelResult>?
    ) -> AnyPublisher<FlowDomain.Event, Never> {
        
        switch result {
        case .none:
            return Empty<FlowDomain.Event, Never>().eraseToAnyPublisher()
            
        case .cancelled:
            return Just(.dismiss).eraseToAnyPublisher()
            
        case .inflight:
            return Empty<FlowDomain.Event, Never>().eraseToAnyPublisher()
            
        case let .qrResult(qrResult):
            return AnyPublisher { completion in
                
                self.nanoServices.makeQRNavigation(qrResult) {
                    
                    completion(.receive(.qrNavigation($0)))
                }
            }.eraseToAnyPublisher()
        }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
