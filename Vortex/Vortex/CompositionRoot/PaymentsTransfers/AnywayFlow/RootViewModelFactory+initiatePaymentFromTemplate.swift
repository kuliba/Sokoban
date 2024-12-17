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
        initiateAnywayPayment(payload: .template(template), completion: completion)
    }
}
