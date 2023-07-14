//
//  TextFieldState+ext.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import TextFieldComponent

// MARK: - Support existing API

extension TextFieldState {
    
    var isEditing: Bool {
        
        switch self {
        case .placeholder, .noFocus:
            return false
            
        case .editing:
            return true
        }
    }
    
    var text: String? {
        
        switch self {
        case .placeholder:
            return nil
            
        case let .noFocus(text):
            return text
            
        case let .editing(state):
            return state.text
        }
    }
}
