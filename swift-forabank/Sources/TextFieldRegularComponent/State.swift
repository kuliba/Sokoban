//
//  State.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

extension TextFieldRegularView.ViewModel {
    
    public enum State: Equatable {
     
        case focus(text: String, cursorPosition: Int)
        case noFocus(String)
        case placeholder(String)
    }
}

extension TextFieldRegularView.ViewModel.State {
    
    public var isEditing: Bool {
        
        switch self {
        case .placeholder, .noFocus:
            return false
            
        case .focus:
            return true
        }
    }
    
    public var text: String? {
        
        switch self {
        case .placeholder:
            return nil
            
        case let .noFocus(text):
            return text
            
        case let .focus(text, _):
            return text
        }
    }
}

extension TextFieldRegularView.ViewModel.State {
    
    public init(text: String? = nil, cursorPosition: Int? = nil, placeholderText: String) {
        
        switch (text, cursorPosition) {
        case let (.some(text), .some(cursorPosition)):
            self = .focus(text: text, cursorPosition: cursorPosition)
            
        case let (.some(text), .none) where !text.isEmpty:
            self = .noFocus(text)
            
        default:
            self = .placeholder(placeholderText)
        }
    }
}
