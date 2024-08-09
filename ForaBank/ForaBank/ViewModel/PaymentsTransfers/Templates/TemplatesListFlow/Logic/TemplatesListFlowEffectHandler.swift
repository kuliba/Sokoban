//
//  TemplatesListFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

final class TemplatesListFlowEffectHandler {
    
    private let makePaymentModel: MakePaymentModel
    
    init(
        makePaymentModel: @escaping MakePaymentModel
    ) {
        self.makePaymentModel = makePaymentModel
    }
    
    typealias MakePaymentModel = (PaymentTemplateData, @escaping () -> Void) -> PaymentsViewModel
}

extension TemplatesListFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .template(template):
            let model = makePaymentModel(template) {
                
                dispatch(.dismiss(.destination))
            }
            dispatch(.payment(model))
        }
    }
}

extension TemplatesListFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TemplatesListFlowEvent
    typealias Effect = TemplatesListFlowEffect
}
