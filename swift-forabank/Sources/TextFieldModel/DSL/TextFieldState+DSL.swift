//
//  TextFieldState+DSL.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

import TextFieldDomain
import Foundation

// MARK: DSL

public extension TextFieldState {
    
    static func editing(_ view: TextState.View) -> Self {
        
        .editing(.init(view.text, cursorPosition: view.cursor))
    }
    
    func paste(_ text: String) throws -> TextFieldAction {
        
        switch self {
        case let .editing(textState):
            let range = NSRange(location: 0, length: textState.text.count)
            return .changeText(text, in: range)
            
        default:
            throw NSError(domain: "Expected `editing` state, got \(String(describing: self))", code: 0)
        }
    }
    
    /// Insert text at cursor assuming no text was selected.
    func insert(_ text: String) throws -> TextFieldAction {
        
        switch self {
        case let .editing(textState):
            let range = NSRange(location: textState.cursorPosition, length: 0)
            return .changeText(text, in: range)
            
        default:
            throw NSError(domain: "Expected `editing` state, got \(String(describing: self))", code: 0)
        }
    }
    
    /// Delete one symbol before cursor if cursor is not at the start of text.
    func delete() throws -> TextFieldAction {
        
        switch self {
        case let .editing(textState):
            guard textState.cursorPosition > 0 else {
                
                throw NSError(domain: "Can't remove before cursor if cursor at start", code: 0)
            }
            
            let range = NSRange(location: textState.cursorPosition - 1, length: 1)
            return .changeText("", in: range)
            
        default:
            throw NSError(domain: "Expected `editing` state, got \(String(describing: self))", code: 0)
        }
    }
    
    /// An action to append provided text.
#warning("add tests")
    func append(_ text: String) throws -> TextFieldAction {
        
        switch self {
        case let .editing(textState):
            let range = NSRange(location: textState.text.count, length: 0)
            return .changeText(text, in: range)
            
        default:
            throw NSError(domain: "Expected `editing` state, got \(String(describing: self))", code: 0)
        }
    }
    
    func removeLast(_ k: Int = 1) throws -> TextFieldAction {
        
        switch self {
        case let .editing(textState):
            guard 0 <= k else {
                
                throw NSError(domain: "Cannot remove negative number of characters.", code: 0)
            }
    
            guard k <= textState.text.count else {
                
                throw NSError(domain: "Cannot remove \(k) character(s) - have only \(textState.text.count)", code: 0)
            }
            
            let range = NSRange(
                location: textState.text.count - k,
                length: k
            )
            return .changeText("", in: range)
            
        default:
            throw NSError(domain: "Expected `editing` state, got \(String(describing: self))", code: 0)
        }
    }
    
    /// Replace selected part of the text after cursor.
    func replace(
        from cursorPosition: Int? = nil,
        count: Int,
        with text: String
    ) throws -> TextFieldAction {
        
        switch self {
        case let .editing(textState):
            let cursorPosition = cursorPosition ?? textState.cursorPosition
            
            let range = NSRange(location: cursorPosition, length: count)
            return .changeText(text, in: range)
            
        default:
            throw NSError(domain: "Expected `editing` state, got \(String(describing: self))", code: 0)
        }
    }
}
