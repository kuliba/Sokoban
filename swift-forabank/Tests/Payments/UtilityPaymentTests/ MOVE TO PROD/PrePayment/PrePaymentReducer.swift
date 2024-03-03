//
//  PrePaymentReducer.swift
//  
//
//  Created by Igor Malyarov on 03.03.2024.
//

final class PrePaymentReducer {
    
}

extension PrePaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
    }
}

extension PrePaymentReducer {
    
    typealias State = PrePaymentState
    typealias Event = PrePaymentEvent
    typealias Effect = Never
}
