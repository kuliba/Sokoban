//
//  InputReducer.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

final class InputReducer<Icon> {}

extension InputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .edit(text):
            state.dynamic.value = text
        }
        
        return (state, effect)
    }
}

extension InputReducer {
    
    typealias State = InputState<Icon>
    typealias Event = InputEvent
    typealias Effect = InputEffect
}
