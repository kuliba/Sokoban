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
    
    typealias OperatorsAndLatest = LoadNanoServices<ServiceCategory, Latest, UtilityPaymentProvider>.Success
    
    @inlinable
    func loadOperatorsAndLatest(
        for category: ServiceCategory,
        completion: @escaping (OperatorsAndLatest?) -> Void
    ) {
        let service = LoadNanoServices(
            loadLatest: loadLatestPayments,
            loadOperators: loadCachedOperators
        )
        
        service.load(category: category) { completion($0); _ = service }
    }
    
    @inlinable
    func makeDestination(
        for category: ServiceCategory,
        and payload: OperatorsAndLatest?
    ) -> StandardSelectedCategoryDestination {
        
        switch payload {
        case .none:
            let failure = makeServiceCategoryFailure(category: category)
            return .failure(failure)
            
        case let .some(operatorsAndLatest):
            let picker = makePaymentProviderPicker(payload: .init(
                category: category,
                latest: operatorsAndLatest.latest,
                operators: operatorsAndLatest.operators
            ))
            return .success(picker)
        }
    }
}
