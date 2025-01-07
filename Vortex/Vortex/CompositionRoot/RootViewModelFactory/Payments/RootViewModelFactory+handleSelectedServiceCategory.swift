//
//  RootViewModelFactory+handleSelectedServiceCategory.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.12.2024.
//

import Combine
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
        loadOperatorsAndLatest(for: category) { [weak self] in
            
            guard let self else { return }
            
            completion(makeDestination(for: category, and: $0))
        }
    }
    
    @inlinable
    func makeDestination(
        for category: ServiceCategory,
        and payload: OperatorsAndLatest?
    ) -> StandardSelectedCategoryDestination {
        
        switch payload {
        case .none:
            return .failure(makeServiceCategoryFailure(category: category))
            
        case let .some(operatorsAndLatest):
            return .success(
                makePaymentProviderPicker(payload: .init(
                    category: category,
                    latest: operatorsAndLatest.latest,
                    operators: operatorsAndLatest.operators
                ))
            )
        }
    }
    
    @inlinable
    func loadOperatorsAndLatest(
        for category: ServiceCategory,
        completion: @escaping (OperatorsAndLatest?) -> Void
    ) {
        let service = LoadNanoServices(
            loadLatest: loadLatestPayments,
            loadOperators: loadOperatorsForCategory
        )
        
        service.load(category: category) {
            
            completion($0?.operatorsAndLatest)
            _ = service
        }
    }
    
    struct OperatorsAndLatest: Equatable {
        
        let latest: [Latest]
        let operators: [UtilityPaymentProvider]
    }
}

// MARK: - Adapters

private extension LoadNanoServices.Success
where Latest == Vortex.Latest,
      Operator == UtilityPaymentProvider {
    
    var operatorsAndLatest: RootViewModelFactory.OperatorsAndLatest {
        
        return .init(latest: latest, operators: operators)
    }
}
