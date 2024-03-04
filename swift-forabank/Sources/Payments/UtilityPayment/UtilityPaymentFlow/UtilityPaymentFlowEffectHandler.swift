//
//  UtilityPaymentFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentFlowEffectHandler {
    
    public init() {}
}

public extension UtilityPaymentFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension UtilityPaymentFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentFlowEvent
    typealias Effect = UtilityPaymentFlowEffect
}
