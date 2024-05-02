//
//  PaymentEffectHandler.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentEffectHandler {}

extension PaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension PaymentEffectHandler {
        
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentEvent
    typealias Effect = PaymentEffect
}
