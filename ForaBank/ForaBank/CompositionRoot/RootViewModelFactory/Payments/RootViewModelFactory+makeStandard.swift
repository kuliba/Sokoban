//
//  RootViewModelFactory+makeStandard.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import PayHub
import RemoteServices

extension RootViewModelFactory {
    
    func makeStandard(
        _ category: ServiceCategory,
        completion: @escaping (StandardSelectedCategoryDestination) -> Void
    ) {
        let nanoServices = makeStandardNanoServices(for: category)
        let composer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: nanoServices
        )
        let standardMicroService = composer.compose()
        
        standardMicroService.makeDestination(category) {
            
            completion($0)
            _ = standardMicroService
        }
    }
}

extension RootViewModelFactory {
    
    @inlinable
    func makeStandardNanoServices(
        for category: ServiceCategory
    ) -> StandardNanoServices {
        
        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        
        return .init(
            loadLatest: { getLatestPayments([category.name], $0) },
            loadOperators: { self.loadOperatorsForCategory(category: category, completion: $0) },
            makeFailure: { $0(.init()) },
            makeSuccess: { payload, completion in
                
                completion(self.makePaymentProviderPicker(payload: payload))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, PaymentServiceOperator, PaymentProviderPickerDomain.Binder, FailedPaymentProviderPickerStub>
}
