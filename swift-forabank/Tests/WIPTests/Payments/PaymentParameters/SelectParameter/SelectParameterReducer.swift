//
//  SelectParameterReducer.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

final class SelectParameterReducer {
    
}

extension SelectParameterReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
        
    }
}

extension SelectParameterReducer {
    
    typealias State = SelectParameter
    typealias Event = SelectParameterEvent
    typealias Effect = SelectParameterEffect
}
