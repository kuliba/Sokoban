//
//  SelectedCategoryNavigationMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

final class SelectedCategoryNavigationMicroServicesComposer<List, ListModel> {
    
#warning("see PaymentFlowMicroServiceComposerNanoServicesComposer")
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = CategoryPickerSectionMicroServicesComposerNanoServices<List, ListModel>
}

extension SelectedCategoryNavigationMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(getNavigation: getNavigation)
    }
    
    typealias Select = CategoryPickerSection.Select
    typealias Navigation = SelectedCategoryNavigation<ListModel>
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias MicroServices = FlowDomain.MicroServices
}

private extension SelectedCategoryNavigationMicroServicesComposer {
    
    typealias Notify = (FlowDomain.Event) -> Void
    
    func getNavigation(
        payload: Select,
        notify: @escaping Notify,
        completion: @escaping (SelectedCategoryNavigation<ListModel>) -> Void
    ) {
        switch payload {
        case let .pickerSelect(pickerSelect):
            getNavigation(pickerSelect: pickerSelect, notify, completion)
            
        case let .qrSelect(qrSelect):
            getNavigation(qrSelect: qrSelect, notify, completion)
        }
    }
    
    // MARK: - PickerSelect
    
    func getNavigation(
        pickerSelect payload: CategoryPickerSection.Select.PickerSelect,
        _ notify: @escaping Notify,
        _ completion: @escaping (SelectedCategoryNavigation<ListModel>) -> Void
    ) {
        switch payload {
        case let .category(category):
            switch category.paymentFlow {
            case .mobile:
                completion(.paymentFlow(.mobile(nanoServices.makeMobile())))
                
            case .qr:
                let qr = nanoServices.makeQR()
                let cancellable = qr.$state
                    .flatMap {
                        
                        self.notifyPublisher(
                            result: $0,
                            notify: { notify(.select(.qrSelect($0))) }
                        )
                    }
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
        result: QRModelWrapperState<QRModelResult>?,
        notify: @escaping (QRNavigationComposer.NotifyEvent) -> Void
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
                
                self.nanoServices.makeQRNavigation(qrResult, notify) {
                    
                    completion(.receive(.qrNavigation($0)))
                }
            }.eraseToAnyPublisher()
        }
    }
    
    // MARK: - QRSelect
    
    func getNavigation(
        qrSelect payload: QRNavigationComposer.NotifyEvent,
        _ notify: @escaping (FlowDomain.Event) -> Void,
        _ completion: @escaping (SelectedCategoryNavigation<ListModel>) -> Void
    ) {
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
