//
//  Mask.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

import Foundation
import TextFieldDomain

public struct Mask {
    
    @usableFromInline
    let pattern: String
    
    @usableFromInline
    let patternChars: [Character]
    
    /// Initializes a mask with a given pattern.
    ///
    /// - Parameter pattern: A string pattern where placeholders are `"N"` or `"_"`.
    @inlinable
    init(pattern: String) {
        
        self.pattern = pattern
        self.patternChars = Array(pattern)
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
    
    /// Applies the mask pattern to the provided unmasked `TextState`.
    ///
    /// - Parameter state: The unmasked `TextState` containing raw text and cursor position.
    /// - Returns: A `TextState` with the mask applied to the text and the cursor correctly positioned.
    @inlinable
    func applyMask(
        to state: TextState
    ) -> TextState {
        
        guard !pattern.isEmpty else { return state }
        guard !state.text.isEmpty else { return .empty }
        
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
    
    /// Removes static characters from the masked input and adjusts the cursor position.
    ///
    /// - Parameter state: The current `TextState` containing masked text and cursor position.
    /// - Returns: A `TextState` with static characters removed and the cursor correctly positioned.
    @inlinable
    func removeMask(
        from state: TextState
    ) -> TextState {
        
        guard !pattern.isEmpty else { return state }
        
        let maskedText = state.text
        let cursorPosition = state.cursorPosition
        
        var rawText = ""
        var rawCursorPosition = 0
        
        let maskedChars = Array(maskedText)
        
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
    func unmask(
        _ range: NSRange
    ) -> NSRange {
        
        guard !pattern.isEmpty else { return range }
        
        var maskIndexMap: [Int] = []
        var unmaskedIndex = 0
        
        // Step 1: Build a mapping from masked indices to unmasked indices
        for patternChar in patternChars {
            
            if patternChar.isPlaceholder {
                // Placeholder character contributes to the unmasked text
                maskIndexMap.append(unmaskedIndex)
                unmaskedIndex += 1
            } else {
                // Static character does not contribute
                maskIndexMap.append(unmaskedIndex)
            }
        }
        
        // Step 2: Clamp the input range to the bounds of the mapping
        let clampedLowerBound = max(0, min(range.location, maskIndexMap.count - 1))
        let clampedUpperBound = max(0, min(range.upperBound, maskIndexMap.count))
        
        // Step 3: Map the clamped range to the unmasked range
        let startUnmaskedIndex = maskIndexMap[clampedLowerBound]
        let endUnmaskedIndex = clampedUpperBound > 0
        ? maskIndexMap[clampedUpperBound - 1] + (patternChars[clampedUpperBound - 1].isPlaceholder ? 1 : 0)
        : startUnmaskedIndex
        
        return .init(location: startUnmaskedIndex, length: endUnmaskedIndex - startUnmaskedIndex)
    }
    
    // remove characters that are not allowed by mask pattern - this is over-simplified (precise should be done in `applyMask`) but could work for `digits-only` masks
    @inlinable
    func clean(
        _ text: String
    ) -> String {
        
        return text.filter(isAllowedByPattern)
    }
    
    @usableFromInline
    func isAllowedByPattern(
        _ character: Character
    ) -> Bool {
        
        guard !pattern.isEmpty else { return true }
        
        guard !pattern.isDigitsOnlyPattern
        else { return character.isNumber }
        
        return true
    }
}

private extension String {
    
    var isDigitsOnlyPattern: Bool {
        
        !contains("_") && contains("N")
    }
}
