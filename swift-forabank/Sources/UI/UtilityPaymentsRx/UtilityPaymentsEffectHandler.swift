//
//  UtilityPaymentsEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public final class UtilityPaymentsEffectHandler {
    
    public init() {}
}

public extension UtilityPaymentsEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension UtilityPaymentsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPaymentsEvent
    typealias Effect = UtilityPaymentsEffect
}
