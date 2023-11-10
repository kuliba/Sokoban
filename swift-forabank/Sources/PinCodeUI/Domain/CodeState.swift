//
//  CodeState.swift
//  
//
//  Created by Andryusina Nataly on 17.07.2023.
//

import SwiftUI

public struct CodeState: Equatable {
    
    public var state: State
    public let title: String
    public var code = ""
    
    public init(
        state: State,
        title: String,
        code: String = ""
    ) {
        
        self.state = state
        self.title = title
        self.code = code
    }
    
    public enum State: Equatable {
        
        case empty
        case firstSet(first: String)
        case confirmSet(first: String, second: String)
        case checkValue(first: String, second: String)
    }
    
    public var titleForView: String {
        
        switch state {
        case .empty, .firstSet:
            return title
        default:
            return "Подтвердите PIN-код\n"
        }
    }
    
    public var hideHint: Bool {
        
        switch state {
        case .empty, .firstSet:
            return false
        default:
            return true
        }
    }

    public var firstValue: String {
        
        switch state {
        case .empty:
             return ""
        case .firstSet(let first):
            return first
        case .confirmSet(let first, _), .checkValue(let first, _):
            return first
        }
    }
    
    public var confirmValue: String {
        
        switch state {
        case .empty, .firstSet(_):
             return ""
        case .confirmSet(_, let second), .checkValue(_, let second):
            return second
        }
    }
    
    public var currentStyle: PinCodeViewModel.Style {
        
        switch state {
            
        case .empty:
            
            return .normal
        case .firstSet, .confirmSet:
            
            return .printing
        case .checkValue(first: let first, second: let second):
            
            if first == second { return .correct }
            else { return .incorrect }
        }
    }
    
    public mutating func updateState(_ newState: State, newCode: String) {
        
        state = newState
        code = newCode
    }
}
