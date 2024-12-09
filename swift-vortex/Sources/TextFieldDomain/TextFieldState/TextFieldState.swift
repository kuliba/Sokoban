//
//  TextFieldState.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

public enum TextFieldState: Equatable {
    
    case placeholder(String)
    case noFocus(String)
    case editing(TextState)
}

extension TextFieldState {
    
    public init(_ placeholderText: String) {
        
        self = .placeholder(placeholderText)
    }
}
