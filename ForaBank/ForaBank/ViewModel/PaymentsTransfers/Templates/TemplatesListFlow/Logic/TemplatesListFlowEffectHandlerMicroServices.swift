//
//  TemplatesListFlowEffectHandlerMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

struct TemplatesListFlowEffectHandlerMicroServices {
    
    let makePayment: MakePayment
}

extension TemplatesListFlowEffectHandlerMicroServices {
    
    typealias MakePaymentPayload = (PaymentTemplateData, () -> Void)
    typealias MakePaymentCompletion = (Payment) -> Void
    typealias MakePayment = (MakePaymentPayload, @escaping MakePaymentCompletion) -> Void
    typealias Payment = TemplatesListFlowEvent.Payment
}
