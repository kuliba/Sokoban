//
//  Reducer+DSL.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

import Foundation
import TextFieldDomain

// MARK: - DSL

extension Reducer {
    
    func reduce(
        _ state: TextFieldState,
        actions: ((TextFieldState) throws -> TextFieldAction)...
    ) throws -> [TextFieldState] {
        
        var state = state
        var result = [state]
        
        for action in actions {
            
            state = try reduce(state, with: action(state))
            result.append(state)
        }
        
        return result
    }
    
    func deleteAfterCursor(
        count: Int,
        in state: TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TextFieldState {
        
        switch state {
        case let .editing(textState):
            let range = NSRange(location: textState.cursorPosition, length: count)
            return try reduce(state, with: .changeText("", in: range))
            
        default:
            throw NSError(domain: "DLS: expected `editing` state.", code: 0)
        }
    }
    
    func insertAtCursor(
        _ text: String,
        in state: TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TextFieldState {
        
        switch state {
        case let .editing(textState):
            let range = NSRange(location: textState.cursorPosition, length: 0)
            return try reduce(state, with: .changeText(text, in: range))
            
        default:
            throw NSError(domain: "DLS: expected `editing` state.", code: 0)
        }
    }
    
    func replaceAfterCursor(
        _ count: Int,
        with text: String,
        in state: TextFieldState,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> TextFieldState {
        
        switch state {
        case let .editing(textState):
            let range = NSRange(location: textState.cursorPosition, length: count)
            return try reduce(state, with: .changeText(text, in: range))
            
        default:
            throw NSError(domain: "DLS: expected `editing` state.", code: 0)
        }
    }
}
