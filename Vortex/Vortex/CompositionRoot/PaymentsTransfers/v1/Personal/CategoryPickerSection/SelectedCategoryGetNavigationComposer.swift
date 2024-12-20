//
//  SelectedCategoryGetNavigationComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

final class SelectedCategoryGetNavigationComposer {
    
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

extension SelectedCategoryGetNavigationComposer {
    
    typealias Domain = CategoryPickerSectionDomain
    typealias Navigation = Domain.Navigation
    
    func getNavigation(
        _ category: Domain.Select,
        _ notify: @escaping Domain.Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.paymentFlow(.mobile(nanoServices.makeMobile())))
            
        case .qr:
            completion(.paymentFlow(.qr(())))
            
        case .standard:
            completion(.paymentFlow(.standard(category)))
            
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
