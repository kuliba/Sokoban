//
//  InputParameterReducer.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

final class InputParameterReducer {
    
}

extension InputParameterReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
        
    }
}

extension InputParameterReducer {
    
    typealias State = InputParameter
    typealias Event = InputParameterEvent
    typealias Effect = InputParameterEffect
}
