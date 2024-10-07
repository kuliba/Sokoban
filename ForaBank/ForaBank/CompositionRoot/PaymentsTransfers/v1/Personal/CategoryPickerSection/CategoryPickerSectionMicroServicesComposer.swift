//
//  CategoryPickerSectionMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class CategoryPickerSectionMicroServicesComposer {
    
#warning("see PaymentFlowMicroServiceComposerNanoServicesComposer")
    private let nanoServices: NanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        nanoServices: NanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.nanoServices = nanoServices
        self.scheduler = scheduler
    }
    
    typealias NanoServices = CategoryPickerSectionMicroServicesComposerNanoServices
}

extension CategoryPickerSectionMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(getNavigation: getNavigation)
    }
    
    typealias MicroServices = CategoryPickerSection.FlowDomain.MicroServices
}

private extension CategoryPickerSectionMicroServicesComposer {
    
    func getNavigation(
        payload: CategoryPickerSection.Select,
        notify: @escaping (CategoryPickerSection.FlowDomain.Event) -> Void,
        completion: @escaping (CategoryPickerSectionNavigation) -> Void
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
            
        case let .list(list):
            completion(.list(.init(categories: list)))
        }
    }
    
    private func notifyPublisher(
        result: QRModelWrapperState<QRModelResult>?
    ) -> AnyPublisher<CategoryPickerSection.FlowDomain.Event, Never> {
        
        switch result {
        case .none:
            return Empty<CategoryPickerSection.FlowDomain.Event, Never>().eraseToAnyPublisher()
            
        case .cancelled:
            return Just(.dismiss).eraseToAnyPublisher()
            
        case .inflight:
            return Empty<CategoryPickerSection.FlowDomain.Event, Never>().eraseToAnyPublisher()
            
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
