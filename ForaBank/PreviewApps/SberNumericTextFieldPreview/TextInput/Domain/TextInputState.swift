//
//  TextInputState.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import TextFieldDomain
import TextFieldUI

struct TextInputState: Equatable {
    
    let keyboard: KeyboardType
    let title: String
    var textField: TextFieldState
    var message: Message?
}

extension TextInputState {
    
    struct Message: Equatable {
        
        let text: String
        let kind: Kind
        
        enum Kind: Equatable {
            
            case hint, warning
        }
    }
}

extension TextInputState.Message {
    
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
