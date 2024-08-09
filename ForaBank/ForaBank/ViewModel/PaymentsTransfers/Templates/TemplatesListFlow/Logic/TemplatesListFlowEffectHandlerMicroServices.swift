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
    
    typealias MakePayment = (PaymentTemplateData, @escaping () -> Void) -> Payment
    typealias Payment = TemplatesListFlowEvent.Payment
}
