//
//  TextFieldState+makeTextFieldState.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.05.2023.
//

import Foundation
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
