//
//  TextState+ext.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

import Foundation

public extension TextState {
    
    static let empty: Self = .init("")

    /// Creates ``TextState`` from a given text, setting cursor position at given or  at the end if nil.
    init(_ text: String, cursorPosition: Int? = nil) {
        
        self.init(text, cursorPosition: cursorPosition ?? text.utf16.count)
    }
    
    /// Returns ``TextState`` after performing text replacement at a given range.
    ///
    /// - Parameters:
    ///   - range: A range of text to replace.
    ///   - replacementText: The proposed text to replace the text in `range`.
    /// - Returns: A new `TextState` reflecting text replacement.
    /// - Note: This method ignores current `cursorPosition`,
    /// replacement range is defined by given range.
    func replace(
        inRange range: NSRange,
        with replacementText: String
    ) throws -> Self {
        
        guard range.isValidForReplacement(in: text) else {
            throw TextStateError.invalidReplacementRange(expectedWithin: .init(location: 0, length: text.count), got: range)
        }
        
        let changed = text.shouldChangeTextIn(range: range, with: replacementText)
        let cursorPosition = range.location + replacementText.utf16.count
        
        return .init(changed, cursorPosition: cursorPosition)
    }
    
    enum TextStateError: Error, Equatable {
        case invalidReplacementRange(expectedWithin: NSRange, got: NSRange)
    }
}

public extension NSRange {
    
    func isValidForReplacement(in text: String) -> Bool {
        
        let valid = (0...text.utf16.count)
        
        return valid ~= location
        && valid ~= length
        && valid ~= location + length
    }
}
