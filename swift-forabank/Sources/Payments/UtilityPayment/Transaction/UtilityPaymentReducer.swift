//
//  UtilityPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentReducer {
    
    public init() {}
}

public extension UtilityPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
                    
        
        return (state, effect)
    }
}

public extension UtilityPaymentReducer {
    
    typealias PrePaymentReduce = (PrePaymentState, PrePaymentEvent) -> (PrePaymentState, PrePaymentEffect?)
    
    typealias State = UtilityPaymentState
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}
