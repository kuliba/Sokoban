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
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, UtilityPaymentProvider, PaymentProviderPickerDomain.Binder, ServiceCategoryFailureDomain.Binder>
    
    @inlinable
    func handleSelectedServiceCategory(
        _ category: ServiceCategory,
        nanoServices: StandardNanoServices,
        completion: @escaping (StandardSelectedCategoryDestination) -> Void
    ) {
        let composer = StandardSelectedCategoryGetNavigationComposer(
            nanoServices: nanoServices
        )
        
        composer.makeDestination(category: category) {
            
            completion($0)
            _ = composer
        }
    }
    
    private func makeNanoServices(
        for category: ServiceCategory
    ) -> StandardNanoServices {
        
        return .init(
            loadLatest: { [weak self] in
                
                self?.loadLatestPayments(for: category, completion: $0)
            },
            loadOperators: { [weak self] in
                
                self?.loadOperatorsForCategory(category: category, completion: $0)
            },
            makeFailure: { [weak self] completion in
                
                guard let self else { return }
                
                completion(makeServiceCategoryFailure(category: category))
            },
            makeSuccess: { [weak self] payload, completion in
                
                guard let self else { return }
                
                completion(makePaymentProviderPicker(payload: payload))
            }
        )
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
