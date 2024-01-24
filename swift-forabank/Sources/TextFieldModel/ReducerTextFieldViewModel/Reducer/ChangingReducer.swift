//
//  ChangingReducer.swift
//
//
//  Created by Igor Malyarov on 26.04.2023.
//

import Foundation
import TextFieldDomain

public struct ChangingReducer {
    
    public typealias Change = (TextState, String, NSRange) throws -> TextState
    
    @usableFromInline
    let placeholderText: String
    
    @usableFromInline
    let change: Change
    
    /// Create Text State `Reducer` with change of the text in the range.
    @inlinable
    public init(
        placeholderText: String,
        change: @escaping Change
    ) {
        self.placeholderText = placeholderText
        self.change = change
    }
}

extension ChangingReducer: Reducer {
    
    @inlinable
    public func reduce(
        _ state: TextFieldState,
        with action: TextFieldAction
    ) throws -> TextFieldState {
        
        switch action {
        case .startEditing:
            switch state {
            case .placeholder:
                return .editing(.empty)
                
            case let .noFocus(text):
                return .editing(.init(text))
                
            case .editing:
                return state
            }
            
        case .finishEditing:
            switch state {
            case .placeholder:
                return .placeholder(placeholderText)
                
            case .noFocus:
                return state
                
            case .editing(.empty):
                return .placeholder(placeholderText)
                
            case let .editing(textState):
                return .noFocus(textState.text)
            }
            
        case let .changeText(replacementText, in: range):
            switch state {
            case .placeholder, .noFocus:
                return state
                
            case let .editing(textState):
                let textState = try change(textState, replacementText, range)
                return .editing(textState)
            }
            
        case .setTextTo(.none):
            return .placeholder(placeholderText)
            
        case .setTextTo(.some("")):
            switch state {
            case .placeholder:
                return .noFocus("")
            case .noFocus:
                return .placeholder(placeholderText)
            case .editing:
                return .editing(.empty)
            }
            
        case let .setTextTo(.some(text)):
            let temp = try change(.empty, text, .zero)
            
            switch state {
            case .placeholder, .noFocus:
                return .noFocus(temp.text)
                
            case let .editing(textState):
                if textState.text == text {
                    return .editing(textState)
                } else {
                    return .editing(.init(temp.text))
                }
            }
        }
    }
}

public extension NSRange {
    
    static let zero = NSRange(location: 0, length: 0)
}

extension ChangingReducer {
    
    @inlinable
    init(
        placeholderText: String,
        transform: @escaping (TextState) -> TextState
    ) {
        self.init(
            placeholderText: placeholderText
        ) { textState, replacementText, range in
            
            let temp = try textState.replace(
                inRange: range,
                with: replacementText
            )
            
            let transformed = transform(temp)
            
            return transformed
        }
    }
}

public extension Reducers {
    
    typealias ChangingReducer = TextFieldModel.ChangingReducer // NB: for discovery
}
