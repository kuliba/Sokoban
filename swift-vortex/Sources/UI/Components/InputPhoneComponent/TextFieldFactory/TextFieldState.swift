//
//  TextFieldState.swift
//
//
//  Created by Дмитрий Савушкин on 06.03.2024.
//

import TextFieldComponent

extension TextFieldState {
    
    static func makeTextFieldState(
        text: String? = nil,
        cursorPosition: Int? = nil,
        placeholderText: String
    ) -> TextFieldState {
        
        switch (text, cursorPosition) {
        case let (.some(text), .some(cursorPosition)):
            return .editing(.init(text, cursorPosition: cursorPosition))
            
        case let (.some(text), .none) where !text.isEmpty:
            return .noFocus(text)
            
        default:
            return .placeholder(placeholderText)
        }
    }
}
