//
//  TemplatesListFlowEffectHandlerMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

struct TemplatesListFlowEffectHandlerMicroServices {
    
    let makePaymentModel: MakePaymentModel
}

extension TemplatesListFlowEffectHandlerMicroServices {
    
    typealias MakePaymentModel = (PaymentTemplateData, @escaping () -> Void) -> PaymentsViewModel
}
