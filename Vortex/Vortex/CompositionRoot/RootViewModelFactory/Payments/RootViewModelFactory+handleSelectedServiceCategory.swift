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
        handleSelectedServiceCategory(
            category,
            nanoServices: makeNanoServices(for: category),
            completion: completion
        )
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
}
