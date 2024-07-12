//
//  InputReducer.swift
//
//
//  Created by Дмитрий Савушкин on 25.04.2024.
//

import Foundation

public final class InputReducer<Icon> {
    
    public init() {}
}

public extension InputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .edit(text):
            state = .init(
                dynamic: .init(
                    value: text
                ),
                settings: state.settings
            )
        }
        
        return (state, nil)
    }
}

public extension InputReducer {
    
    typealias State = InputState<Icon>
    typealias Event = InputEvent
    typealias Effect = Never
}
