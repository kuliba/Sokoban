//
//  TextInputReducer.swift
//  
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain

final class TextInputReducer {
    
    private let textFieldReduce: TextFieldReduce
    private let validate: Validate
    
    init(
        textFieldReduce: @escaping TextFieldReduce,
        validate: @escaping Validate
    ) {
        self.textFieldReduce = textFieldReduce
        self.validate = validate
    }
    
    typealias TextFieldReduce = (TextFieldState, TextFieldAction) -> TextFieldState
    typealias Validate = (TextFieldState) -> State.Message?
}

extension TextInputReducer {
    
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

extension TextInputReducer {
    
    typealias State = TextInputState
    typealias Event = TextInputEvent
    typealias Effect = TextInputEffect
}
