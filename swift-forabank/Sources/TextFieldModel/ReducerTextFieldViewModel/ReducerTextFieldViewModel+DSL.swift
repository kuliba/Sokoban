//
//  ReducerTextFieldViewModel+DSL.swift
//  
//
//  Created by Igor Malyarov on 01.06.2023.
//

import Foundation
import TextFieldDomain

// MARK: - DSL

extension ReducerTextFieldViewModel {
    
    func append(_ text: String) throws {
        
        reduce(try state.append(text))
    }
    
    func removeLast(_ k: Int = 1) throws {
        
        reduce(try state.removeLast(k))
    }
}

extension TextFieldAction {
    
    /// An action to append provided text.
    static func append(_ text: String, to textState: TextState) -> Self {
        
        let range = NSRange(location: textState.text.count, length: 0)
        return .changeText(text, in: range)
    }
}
