//
//  TextFieldAction.swift
//  
//
//  Created by Igor Malyarov on 14.04.2023.
//

import Foundation

public enum TextFieldAction: Equatable {
    
    case startEditing, finishEditing
    case changeText(String, in: NSRange)
    case setTextTo(String?)
}
