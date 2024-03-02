//
//  UtilityPaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

final class UtilityPaymentEffectHandler {}

extension UtilityPaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

extension UtilityPaymentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}
