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
    
    func getNavigation(
        _ category: CategoryPickerSectionDomain.Select,
        _ notify: @escaping CategoryPickerSectionDomain.Notify,
        _ completion: @escaping (CategoryPickerSectionDomain.Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.destination(.mobile(nanoServices.makeMobile())))
            
        case .qr:
            completion(.outside(.qr))
            
        case .standard:
            completion(.outside(.standard(category)))
            
        case .taxAndStateServices:
            completion(.destination(.taxAndStateServices(nanoServices.makeTax())))
            
        case .transport:
            guard let transport = nanoServices.makeTransport()
            else { return completion(.failure(.transport)) }
            
            completion(.destination(.transport(transport)))
        }
    }
    
    func getNavigation(
        _ category: CategoryPickerViewDomain.Select,
        _ notify: @escaping CategoryPickerViewDomain.Notify,
        _ completion: @escaping (CategoryPickerViewDomain.Navigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.destination(.mobile(nanoServices.makeMobile())))
            
        case .qr:
            completion(.outside(.qr))
            
        case .standard:
            nanoServices.makeStandard(category) {
                
                completion(.destination(.standard($0)))
            }
            
        case .taxAndStateServices:
            completion(.destination(.taxAndStateServices(nanoServices.makeTax())))
            
        case .transport:
            guard let transport = nanoServices.makeTransport()
            else { return completion(.failure(.transport)) }
            
            completion(.destination(.transport(transport)))
        }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
