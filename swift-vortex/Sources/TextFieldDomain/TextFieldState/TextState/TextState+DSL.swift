//
//  TextState+DSL.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

import Foundation

// MARK: DSL

public extension TextState {
    
    /// Append provided text.
    func append(_ text: String) -> Self {
        
        .init(
            parts.beforeCursor + text + parts.afterCursor,
            cursorPosition: cursorPosition + text.count
        )
    }
    
    /// Removes the specified number of characters from text from the end of the text.
    /// - Parameter k: The number of elements to remove from the text. `k` must be greater than or equal to zero and must not exceed the text length.
    func removeLast(_ k: Int = 1) throws -> Self {
        
        guard k != 0 else { return self }
        
        guard k >= 0 else {
            
        throw NSError(domain: "Cannot remove negative number of characters from text.", code: 0)
        }
        
        guard k <= text.count else {
            
            throw NSError(domain: "Cannot remove \(k) character(s) - have only \(text.count)", code: 0)
        }
        
        let text = text.prefix(text.count - k)
        
        return .init(
            .init(text),
            cursorPosition: text.count
        )
    }

    // MARK: - Helpers
    
    var cursorIndex: String.Index {
        
        .init(utf16Offset: cursorPosition, in: text)
    }
    
    var beforeCursor: String {
        
        .init(text.prefix(upTo: cursorIndex))
    }
    
    var afterCursor: String {
        
        .init(text.suffix(from: cursorIndex))
    }
    
    var view: View {
        
        .init(text, cursorAt: cursorPosition)
    }
    
    struct View: Equatable {
        
        public let text: String
        public let cursor: Int
        
        /// Creates `TextState.View` with text and cursor position.
        public init(_ text: String, cursorAt cursor: Int) {
            self.text = text
            self.cursor = cursor
        }
    }

    var parts: Parts {
        
        .init(text, beforeCursor, afterCursor)
    }
    
    struct Parts: Equatable {
        
        let text: String
        let beforeCursor: String
        let afterCursor: String
        
        init(_ text: String, _ beforeCursor: String, _ afterCursor: String) {
            self.text = text
            self.beforeCursor = beforeCursor
            self.afterCursor = afterCursor
        }
    }
    
    // MARK: - actions: all functions have the same signature: (TextState) -> TextState
    
    func moveCursorLeft() -> Self {
        
        .init(
            text,
            cursorPosition: max(0, cursorPosition - 1)
        )
    }
    
    func moveCursorRight() -> Self {
        
        .init(
            text,
            cursorPosition: min(text.count, cursorPosition + 1)
        )
    }
    
    func insertAtCursor(_ text: String) -> Self {
        
        .init(
            self.text.shouldChangeTextIn(
                range: .init(location: cursorPosition, length: 0),
                with: text
            ),
            cursorPosition: cursorPosition + text.count
        )
    }
    
    func replaceSelected(
        count: Int,
        with text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Self {
        
        try replace(
            inRange: .init(location: cursorPosition, length: count),
            with: text
        )
    }
    
    func deleteBeforeCursor() throws -> Self {
        
        try replace(
            inRange: .init(location: cursorPosition - 1, length: 1),
            with: ""
        )
    }
    
    // MARK: - apply multiple actions
    
    func reduce(
        actions: ((Self) throws -> Self)...
    ) throws -> [Self] {
        
        var state = self
        var result = [state]
        
        for action in actions {
            
            state = try action(state)
            result.append(state)
        }
        
        return result
    }
}
