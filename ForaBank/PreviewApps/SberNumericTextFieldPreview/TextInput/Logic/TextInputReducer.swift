//
//  TextInputReducer.swift
//  SberNumericTextFieldPreview
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain

final class TextInputReducer {
    
    private let textFieldReduce: TextFieldReduce
    
    init(
        textFieldReduce: @escaping TextFieldReduce
    ) {
        self.textFieldReduce = textFieldReduce
    }
    
    typealias TextFieldReduce = (TextFieldState, TextFieldAction) -> TextFieldState
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
            state.textField = textFieldReduce(state.textField, textFieldAction)
        }
        
        return (state, effect)
    }
}

extension TextInputReducer {
    
    typealias State = TextInputState
    typealias Event = TextInputEvent
    typealias Effect = TextInputEffect
}
