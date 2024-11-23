//
//  RootViewModelFactory+initiatePaymentFromTemplate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.11.2024.
//

extension RootViewModelFactory {
    
    @inlinable
    func initiatePaymentFromTemplate(
        template: PaymentTemplateData,
        completion: @escaping (Result<AnywayFlowModel, ServiceFailureAlert.ServiceFailure>) -> Void
    ) {
        let anywayFlowComposer = makeAnywayFlowComposer()
        
        initiatePaymentFromTemplate(template) {
            
            switch $0 {
            case let .failure(serviceFailure):
                completion(.failure(serviceFailure))
                
            case let .success(transaction):
                completion(.success(anywayFlowComposer.compose(transaction: transaction)))
            }
        }
    }
    
    @inlinable
    func initiatePaymentFromTemplate(
        _ template: PaymentTemplateData,
        completion: @escaping (Result<AnywayTransactionState.Transaction, ServiceFailureAlert.ServiceFailure>) -> Void
    ) {
        let composer = makeInitiateAnywayPaymentMicroServiceComposer()
        let initiatePaymentMicroService = composer.compose()
        let initiatePayment = initiatePaymentMicroService.initiatePayment
        
        initiatePayment(.template(template)) {
            
            completion($0)
            _ = initiatePayment
        }
    }
}
