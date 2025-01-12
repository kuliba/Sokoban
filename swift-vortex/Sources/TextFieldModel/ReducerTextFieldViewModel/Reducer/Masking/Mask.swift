//
//  Mask.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

import Foundation
import TextFieldDomain

@usableFromInline
struct Mask {
    
    @usableFromInline
    let pattern: String
    
    @usableFromInline
    let patternChars: [Character]
    
    @usableFromInline
    let maskIndexMap: [(lower: Int, upper: Int)]
    
    /// Initializes a mask with a given pattern.
    ///
    /// - Parameter pattern: A string pattern where placeholders are `"N"` or `"_"`.
    @usableFromInline
    init(pattern: String) {
        
        self.pattern = pattern
        self.patternChars = Array(pattern)
        self.maskIndexMap = patternChars.buildMapping()
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
    @usableFromInline
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
    @usableFromInline
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
}

extension Mask {
    
    /// Maps a range in the masked text to the corresponding range in the unmasked text.
    ///
    /// - Parameter range: The range in the masked text.
    /// - Returns: The corresponding range in the unmasked text.
    @usableFromInline
    func unmask(
        _ range: NSRange
    ) -> NSRange {
        
        guard !pattern.isEmpty else { return range }
        
        // Step 1: Clamp the input range to the bounds of the mapping
        let clampedLowerBound = max(0, min(range.location, maskIndexMap.count - 1))
        let clampedUpperBound = max(0, min(range.upperBound, maskIndexMap.count))
        
        // Step 2: Use `lower` for the start, `upper` for the end
        let startUnmaskedIndex = maskIndexMap[clampedLowerBound].lower
        let endUnmaskedIndex = clampedUpperBound > 0
        ? maskIndexMap[clampedUpperBound - 1].upper
        : startUnmaskedIndex
        
        // Step 3: Construct the new range
        return .init(location: startUnmaskedIndex, length: endUnmaskedIndex - startUnmaskedIndex)
    }
}

extension Array where Element == Character {
    
    /// Builds a mapping from masked indices to unmasked index ranges.
    ///
    /// Each masked character maps to a tuple `(lower, upper)` in the unmasked text.
    /// - Placeholders increment the unmasked index.
    /// - Static characters map to the same index for both `lower` and `upper`.
    @inlinable
    func buildMapping() -> [(lower: Int, upper: Int)] {
        
        var maskIndexMap: [(lower: Int, upper: Int)] = []
        var unmaskedIndex = 0
        
        for patternChar in self {
            
            if patternChar.isPlaceholder {
                // Placeholder contributes to unmasked text, so advance the index
                maskIndexMap.append((unmaskedIndex, unmaskedIndex + 1))
                unmaskedIndex += 1
            } else {
                // Static characters do not contribute to unmasked text
                maskIndexMap.append((unmaskedIndex, unmaskedIndex))
            }
        }
        
        return maskIndexMap
    }
}

extension Mask {

    // remove characters that are not allowed by mask pattern - this is over-simplified (precise should be done in `applyMask`) but could work for `digits-only` masks
    @usableFromInline
    func clean(
        _ text: String
    ) -> String {
        
        return text.filter(isAllowedByPattern)
    }
    
    @usableFromInline
    internal func isAllowedByPattern(
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
