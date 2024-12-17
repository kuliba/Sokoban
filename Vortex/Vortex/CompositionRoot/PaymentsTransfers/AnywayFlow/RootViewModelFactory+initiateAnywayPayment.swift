//
//  RootViewModelFactory+initiateAnywayPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.12.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func initiateAnywayPayment(
        payload: AnywayPaymentSourceParser.Source,
        completion: @escaping (Result<AnywayFlowModel, ServiceFailureAlert.ServiceFailure>) -> Void
    ) {
        let anywayFlowComposer = makeAnywayFlowComposer()
        
        initiateAnywayPayment(payload) {
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(transaction):
                completion(.success(anywayFlowComposer.compose(transaction: transaction)))
            }
        }
    }
    
    @inlinable
    func initiateAnywayPayment(
        _ payload: AnywayPaymentSourceParser.Source,
        completion: @escaping (Result<AnywayTransactionState.Transaction, ServiceFailureAlert.ServiceFailure>) -> Void
    ) {
        let composer = makeInitiateAnywayPaymentMicroServiceComposer()
        let microService = composer.compose()
        let initiatePayment = microService.initiatePayment
        
        initiatePayment(payload) {
            
            completion($0)
            _ = initiatePayment
        }
    }
}
