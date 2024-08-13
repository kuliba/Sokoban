//
//  TextInputReducer.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain

public final class TextInputReducer {
    
    private let textFieldReduce: TextFieldReduce
    private let validate: Validate
    
    public init(
        textFieldReduce: @escaping TextFieldReduce,
        validate: @escaping Validate
    ) {
        self.textFieldReduce = textFieldReduce
        self.validate = validate
    }
}

public extension TextInputReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        let effect: Effect? = nil
        
        switch event {
        case let .textField(textFieldAction):
            let textField = textFieldReduce(state.textField, textFieldAction)
            let message = validate(textField)
            state.textField = textField
            state.message = message
        }
        
        return (state, effect)
    }
}

public extension TextInputReducer {
    
    typealias TextFieldReduce = (TextFieldState, TextFieldAction) -> TextFieldState
    typealias Validate = (TextFieldState) -> State.Message?
    
    typealias State = TextInputState
    typealias Event = TextInputEvent
    typealias Effect = TextInputEffect
}
