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
    
    /// For each `i` in `patternChars`, store `(lower, upper)` to be used in `unmask(_:)`.
    ///
    /// - lower: unmasked index if `i` is used as the **start** (lower bound).
    /// - upper: unmasked index if `i` is used as the **end** (exclusive).
    @usableFromInline
    let boundMap: [(lower: Int, upper: Int)]
    
    @usableFromInline
    init(pattern: String) {
        
        self.pattern = pattern
        self.patternChars = Array(pattern)
        self.boundMap = patternChars.buildBoundMap()
    }
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
    
    /// Converts a masked range to the corresponding range in the unmasked text.
    ///
    /// - For empty masked ranges (length=0), returns a zero-length unmasked range at `boundMap[loc].lower`.
    /// - For non-empty, uses `boundMap[start].lower` and `boundMap[end-1].upper`.
    @usableFromInline
    func unmask(_ range: NSRange) -> NSRange {
        
        let count = patternChars.count
        guard count > 0 else { return range }
        
        // If zero-length, just map location to `.lower`.
        if range.length == 0 {
            let clampedLoc = min(range.location, count - 1)
            let lower = boundMap[clampedLoc].lower
            return NSRange(location: lower, length: 0)
        }
        
        // Start = range.location
        // End   = range.location + range.length (exclusive)
        let maskedStart = range.location
        let maskedEnd   = range.location + range.length
        
        // Clamp to [0, count]
        let s = max(0, min(maskedStart, count - 1))
        let e = max(s+1, min(maskedEnd, count)) // ensure e > s
        
        // Translate:
        //  - start → .lower
        //  - end-1 → .upper
        let unmaskedStart = boundMap[s].lower
        let unmaskedEnd   = boundMap[e - 1].upper
        
        let length = max(0, unmaskedEnd - unmaskedStart)
        return NSRange(location: unmaskedStart, length: length)
    }
}

extension Character {
    
    /// Indicates if the character is a placeholder in the mask.
    ///
    /// - Returns: `true` if the character is `"N"` or `"_"`, otherwise `false`.
    @usableFromInline
    var isPlaceholder: Bool { self == "N" || self == "_" }
}

extension Array where Element == Character {
    
    /// Builds `(lower, upper)` for each character in `chars`.
    ///
    /// - Placeholders (`isPlaceholder == true`) each consume one unmasked slot,
    ///   so `(lower = next, upper = next+1)`, then increment `next`.
    /// - Static characters do not consume a new slot. They use `(lower = lastPlaceholder, upper = lastPlaceholder + 1)`.
    ///   This ensures single-char deletions at static positions remove the preceding placeholder.
    ///
    func buildBoundMap() -> [(Int, Int)] {
        
        var result: [(Int, Int)] = []
        result.reserveCapacity(count)
        
        var lastPlaceholderIndex = 0 // track the last used unmasked index
        var nextPlaceholderIndex = 0 // how many placeholders we've seen
        
        for ch in self {
            
            if ch.isPlaceholder {
                
                // Each placeholder consumes one unmasked slot
                result.append((nextPlaceholderIndex, nextPlaceholderIndex + 1))
                lastPlaceholderIndex = nextPlaceholderIndex
                nextPlaceholderIndex += 1
                
            } else {
                
                // Static char => to allow single-character deletion removing the *preceding* placeholder,
                // set upper = lastPlaceholderIndex + 1
                // lower = lastPlaceholderIndex
                // So if user "deletes" the dash, we actually remove the preceding placeholder in unmasked text.
                let lower = lastPlaceholderIndex
                let upper = lastPlaceholderIndex + 1  // crucial for removing preceding digit
                
                result.append((lower, upper))
            }
        }
        
        return result
    }
}

extension Mask {
    
    // remove characters that are not allowed by mask pattern - this is over-simplified (precise should be done in `applyMask`) but work for `digits-only` masks
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
