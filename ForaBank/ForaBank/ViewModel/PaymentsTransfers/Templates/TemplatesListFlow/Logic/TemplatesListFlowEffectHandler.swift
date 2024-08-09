//
//  TemplatesListFlowEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

final class TemplatesListFlowEffectHandler {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = TemplatesListFlowEffectHandlerMicroServices
}

extension TemplatesListFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .template(template):
            let payment = microServices.makePayment(template) {
                
                dispatch(.dismiss(.destination))
            }
            dispatch(.payment(payment))
        }
    }
}

extension TemplatesListFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TemplatesListFlowEvent
    typealias Effect = TemplatesListFlowEffect
}
