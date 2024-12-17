//
//  RootViewModelFactory+makeInitiateAnywayPaymentMicroServiceComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func makeInitiateAnywayPaymentMicroServiceComposer(
    ) -> InitiateAnywayPaymentMicroServiceComposer {
        
        let initiatePayment = NanoServices.initiateAnywayPayment(
            httpClient: httpClient,
            log: logger.log,
            scheduler: schedulers.main
        )
        
        return .init(
            getOutlineProduct: { _ in self.model.outlineProduct() },
            processPayload: { payload, completion in
                
                initiatePayment(payload.outline.payload.puref) {
                    
                    switch $0 {
                    case let .failure(serviceFailure):
                        switch serviceFailure {
                        case .connectivityError:
                            completion(.failure(.connectivityError))
                            
                        case let .serverError(message):
                            completion(.failure(.serverError(message)))
                        }
                        
                    case let .success(response):
                        completion(.success(response))
                    }
                }
            }
        )
    }
}
