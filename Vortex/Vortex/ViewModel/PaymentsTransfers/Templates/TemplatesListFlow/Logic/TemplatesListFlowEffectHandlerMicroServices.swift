//
//  TemplatesListFlowEffectHandlerMicroServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.08.2024.
//

struct TemplatesListFlowEffectHandlerMicroServices<Legacy, V1> {
    
    let makePayment: MakePayment
    let makeTemplates: MakeTemplatesListViewModel
}

extension TemplatesListFlowEffectHandlerMicroServices {
    
    typealias MakePaymentPayload = (PaymentTemplateData, () -> Void)
    typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
    typealias MakePaymentResult = Result<Payment, ServiceFailure>
    typealias MakePaymentCompletion = (MakePaymentResult) -> Void
    typealias MakePayment = (MakePaymentPayload, @escaping MakePaymentCompletion) -> Void
    typealias MakeTemplatesListViewModel = (@escaping () -> Void) -> TemplatesListViewModel

    enum Payment {
        
        case legacy(Legacy)
        case v1(V1)
    }
}
