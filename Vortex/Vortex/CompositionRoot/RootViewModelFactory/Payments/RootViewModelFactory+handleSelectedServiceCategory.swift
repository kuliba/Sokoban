//
//  RootViewModelFactory+handleSelectedServiceCategory.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.12.2024.
//

import Combine
import Foundation
import PayHub
import RemoteServices

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPickerDomain.Binder, ServiceCategoryFailureDomain.Binder>

extension ServiceCategoryFailureDomain.Binder: Error {}

extension RootViewModelFactory {
    
    @inlinable
    func handleSelectedServiceCategory(
        _ category: ServiceCategory,
        completion: @escaping (StandardSelectedCategoryDestination) -> Void
    ) {
        loadCachedOperators(forCategory: category) { [weak self] in
            
            guard let self else { return }
            
            completion(makeDestination(for: category, and: try? $0.get()))
        }
    }
    
    @inlinable
    func makeDestination(
        for category: ServiceCategory,
        and operators: [UtilityPaymentProvider]?
    ) -> StandardSelectedCategoryDestination {
        
        switch operators {
        case .none:
            let failure = makeServiceCategoryFailure(category: category)
            return .failure(failure)
            
        case let .some(operators):
            let picker = makePaymentProviderPicker(payload: .init(
                category: category,
                operators: operators
            ))
            return .success(picker)
        }
    }
}
