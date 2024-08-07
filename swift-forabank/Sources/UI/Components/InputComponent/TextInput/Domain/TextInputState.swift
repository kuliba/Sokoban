//
//  TextInputState.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain
import TextFieldUI

public struct TextInputState: Equatable {
    
    public let keyboard: KeyboardType
    public let title: String
    public var textField: TextFieldState
    public var message: Message?
    
    public init(
        keyboard: KeyboardType, 
        title: String,
        textField: TextFieldState,
        message: Message? = nil
    ) {
        self.keyboard = keyboard
        self.title = title
        self.textField = textField
        self.message = message
    }
}

extension TextInputState {
    
    public struct Message: Equatable {
        
        public let text: String
        public let kind: Kind
        
        public init(
            text: String, 
            kind: Kind
        ) {
            self.text = text
            self.kind = kind
        }
        
        public enum Kind: Equatable {
            
            case hint, warning
        }
    }
}

public extension TextInputState.Message {
    
    static func hint(
        _ text: String
    ) -> Self {
        
        return .init(text: text, kind: .hint)
    }
    
    static func warning(
        _ text: String
    ) -> Self {
        
        return .init(text: text, kind: .warning)
    }
}
