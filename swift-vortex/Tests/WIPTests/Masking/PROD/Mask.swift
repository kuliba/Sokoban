//
//  Mask.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

import TextFieldDomain

#warning("edge case: deleting before first character in unmasked text should have no effect if unmasked text is not empty and set to empty masked text if unmasked text is empty -??")

struct Mask {
    
    private let pattern: String
    
    /// Initializes a mask with a given pattern.
    ///
    /// - Parameter pattern: A string pattern where placeholders are `"N"` or `"_"`.
    @inlinable
    init(pattern: String) {
        
        self.pattern = pattern
    }
}

extension Character {
    
    /// Indicates if the character is a placeholder in the mask.
    ///
    /// - Returns: `true` if the character is `"N"` or `"_"`, otherwise `false`.
    @usableFromInline
    var isPlaceholder: Bool { self == "N" || self == "_" }
}

extension Mask {
    
    /// Removes static characters from the masked input and adjusts the cursor position.
    ///
    /// - Parameter state: The current `TextState` containing masked text and cursor position.
    /// - Returns: A `TextState` with static characters removed and the cursor correctly positioned.
    @inlinable
    func unmask(
        _ state: TextState
    ) -> TextState {
        
        guard !pattern.isEmpty else { return state }
        
        let maskedText = state.text
        let cursorPosition = state.cursorPosition
        
        var rawText = ""
        var rawCursorPosition = 0
        
        let maskedChars = Array(maskedText)
        let patternChars = Array(pattern)
        
        var rawIndex = 0
        
        for (index, char) in maskedChars.enumerated() {
            
            if index >= patternChars.count {
                break // Ignore any extra characters beyond the mask
            }
            
            let patternChar = patternChars[index]
            
            if patternChar.isPlaceholder {
                
                rawText.append(char)
                
                if index < cursorPosition {
                    rawCursorPosition += 1
                }
                
                rawIndex += 1
            } else {
                
                // Skip non-placeholder
                if index < cursorPosition {
                    // If cursor was after this static character, shift left
                    rawCursorPosition = rawIndex
                }
            }
        }
        
        return .init(rawText, cursorPosition: rawCursorPosition)
    }
    
    /// Maps a range in the masked text to the corresponding range in the unmasked text.
    ///
    /// - Parameter range: The range in the masked text.
    /// - Returns: The corresponding range in the unmasked text.
    @inlinable
    func unmask(_ range: Range<Int>) -> Range<Int> {
        
        guard !pattern.isEmpty else { return range }
        
        let patternChars = Array(pattern)
        
        var maskedToUnmasked: [Int] = []
        var unmaskedIndex = 0
        
        // Step 1: Build a mapping from masked indices to unmasked indices
        for patternChar in patternChars {
            
            if patternChar.isPlaceholder {
                // Placeholder character contributes to the unmasked text
                maskedToUnmasked.append(unmaskedIndex)
                unmaskedIndex += 1
            } else {
                // Static character does not contribute
                maskedToUnmasked.append(unmaskedIndex)
            }
        }
        
        // Step 2: Clamp the input range to the bounds of the mapping
        let clampedLowerBound = max(0, min(range.lowerBound, maskedToUnmasked.count - 1))
        let clampedUpperBound = max(0, min(range.upperBound, maskedToUnmasked.count))
        
        // Step 3: Map the clamped range to the unmasked range
        let startUnmaskedIndex = maskedToUnmasked[clampedLowerBound]
        let endUnmaskedIndex = clampedUpperBound > 0
        ? maskedToUnmasked[clampedUpperBound - 1] + (patternChars[clampedUpperBound - 1].isPlaceholder ? 1 : 0)
        : startUnmaskedIndex
        
        return startUnmaskedIndex..<endUnmaskedIndex
    }
    
    /// Applies the mask pattern to the provided unmasked `TextState`.
    ///
    /// - Parameter state: The unmasked `TextState` containing raw text and cursor position.
    /// - Returns: A `TextState` with the mask applied to the text and the cursor correctly positioned.
    @inlinable
    func mask(
        _ state: TextState
    ) -> TextState {
        
        guard !pattern.isEmpty else { return state }
        guard !state.text.isEmpty else { return .empty }
        
        let patternChars = Array(pattern)
        let rawChars = Array(state.text)
        
        var rawIndex = 0
        var maskedText = ""
        
        for patternChar in patternChars {
            
            if patternChar.isPlaceholder {
                
                if rawIndex < rawChars.count {
                    
                    maskedText.append(rawChars[rawIndex])
                    rawIndex += 1
                    
                } else {
                    break
                }
                
            } else {
                
                // Reveal static characters only when there's preceding input
                maskedText.append(patternChar)
            }
        }
        
        let maskedCursorPosition = pattern.maskedIndex(
            for: state.cursorPosition
        )
        
        return .init(maskedText, cursorPosition: maskedCursorPosition)
    }
}
