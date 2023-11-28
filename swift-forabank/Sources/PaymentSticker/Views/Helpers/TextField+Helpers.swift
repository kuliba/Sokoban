//
//  TextField+Helpers.swift
//
//
//  Created by Дмитрий Савушкин on 28.11.2023.
//

import Foundation
import TextFieldDomain

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
