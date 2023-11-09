//
//  TextState.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

/// A type representing a text field in the editing state: a `text` in the text field and current `cursor position`.
public struct TextState: Equatable {
    
    public let text: String
    public let cursorPosition: Int
    
    /// Creates ``TextState`` from given `text` and `cursor position`.
    ///
    /// - Note: Does not allow creation of illegal state: cursor position
    /// must be in the range from 0 to text length, if impossible
    /// `cursor position` is given it is set to the text end.
    public init(_ text: String, cursorPosition: Int) {
        
        self.text = text
        
        if (0...text.utf16.count) ~= cursorPosition {
            self.cursorPosition = cursorPosition
        } else {
            self.cursorPosition = text.utf16.count
        }
    }
}
