//
//  UtilityPaymentsReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public final class UtilityPaymentsReducer {
    
    public init() {}
}

public extension UtilityPaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
    }
}

public extension UtilityPaymentsReducer {
    
    typealias State = UtilityPaymentsState
    typealias Event = UtilityPaymentsEvent
    typealias Effect = UtilityPaymentsEffect
}
