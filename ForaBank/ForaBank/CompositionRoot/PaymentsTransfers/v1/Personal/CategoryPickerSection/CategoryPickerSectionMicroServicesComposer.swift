//
//  CategoryPickerSectionMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

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
        completion: @escaping (CategoryPickerSectionNavigation) -> Void
    ) {
        switch payload {
        case let .category(category):
            switch category.paymentFlow {
            case .mobile:
                completion(.paymentFlow(.mobile(nanoServices.makeMobile())))
                
            case .qr:
                completion(.paymentFlow(.qr(nanoServices.makeQR())))
                
            case .standard:
                nanoServices.makeStandard(category) {
                    
                    completion(.paymentFlow(.standard($0)))
                }
                
            case .taxAndStateServices:
                completion(.paymentFlow(.taxAndStateServices(nanoServices.makeTax())))
                
            case .transport:
                guard let transport = nanoServices.makeTransport() else {
                    
                    return completion(.failure(.init(
                        id: .init(),
                        message: "Ошибка создания транспортных платежей"
                    )))
                }
                
                completion(.paymentFlow(.transport(transport)))
            }
            
        case let .list(list):
            completion(.list(.init(categories: list)))
        }
    }
}
