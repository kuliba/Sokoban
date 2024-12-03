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

final class SelectedCategoryNavigationMicroServicesComposer {
    
    private let model: Model
    private let nanoServices: NanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        nanoServices: NanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.nanoServices = nanoServices
        self.scheduler = scheduler
    }
    
    typealias NanoServices = CategoryPickerSectionMicroServicesComposerNanoServices
}

extension SelectedCategoryNavigationMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(getNavigation: getNavigation)
    }
    
    typealias Domain = CategoryPickerSectionDomain
    typealias Select = Domain.Select
    typealias Navigation = Domain.Navigation
    typealias FlowDomain = Domain.FlowDomain
    typealias MicroServices = FlowDomain.MicroServices
}

private extension SelectedCategoryNavigationMicroServicesComposer {
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    func getNavigation(
        category: ServiceCategory,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.paymentFlow(.mobile(nanoServices.makeMobile())))
            
        case .qr:
            completion(.paymentFlow(.qr(())))
            
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
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
