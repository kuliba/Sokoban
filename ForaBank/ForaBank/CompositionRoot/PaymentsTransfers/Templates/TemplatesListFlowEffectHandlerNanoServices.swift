//
//  TemplatesListFlowEffectHandlerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

struct TemplatesListFlowEffectHandlerNanoServices {
    
    let initiatePayment: InitiatePayment
}

extension TemplatesListFlowEffectHandlerNanoServices {
    
    typealias InitiatePaymentPayload = PaymentTemplateData
    typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
    typealias InitiatePaymentCompletion = (Result<Int, ServiceFailure>) -> Void
    typealias InitiatePayment = (InitiatePaymentPayload, @escaping InitiatePaymentCompletion) -> Void
}
