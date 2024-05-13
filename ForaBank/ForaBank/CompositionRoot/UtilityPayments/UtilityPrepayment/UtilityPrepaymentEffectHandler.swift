//
//  UtilityPrepaymentEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 09.05.2024.
//

final class UtilityPrepaymentEffectHandler {}

extension UtilityPrepaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
#warning("add search debounce, remove duplicates")
        }
    }
}

extension UtilityPrepaymentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityPrepaymentEvent
    typealias Effect = UtilityPrepaymentEffect
}
