//
//  UtilityPaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentEffectHandler {
    
    public init() {}
}

public extension UtilityPaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension UtilityPaymentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}
