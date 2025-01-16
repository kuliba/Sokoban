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
    /// - lower: The unmasked index to use if `i` is the **start** (lower bound) of a range.
    /// - upper: The unmasked index to use if `i` is the **end** (exclusive) of a range.
    ///
    /// This allows single-character deletions over static characters to remove the preceding placeholder
    /// if the mask logic requires that behavior.
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
    
    /// Applies the mask pattern to the given unmasked `TextState`.
    ///
    /// Transforms raw text and the cursor position into their masked equivalents.
    /// For instance, in a phone number mask, a static prefix might appear after typing
    /// enough digits in the unmasked string.
    ///
    /// - Parameter state: The unmasked `TextState` (raw text and cursor position).
    /// - Returns: A new `TextState` with the mask applied to the text and the cursor.
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
                
                // Reveal static characters only when there's preceding input.
                maskedText.append(patternChar)
            }
        }
        
        // Convert the raw cursor position to the masked domain.
        let maskedCursorPosition = pattern.maskedIndex(
            for: state.cursorPosition
        )
        
        return .init(maskedText, cursorPosition: maskedCursorPosition)
    }
    
    /// Removes non-placeholder (static) characters from the masked input and adjusts the cursor.
    ///
    /// This strips out all static characters, leaving only the placeholder-driven text,
    /// and repositions the cursor so it aligns with the unmasked text.
    ///
    /// - Parameter state: The current `TextState` (masked text and cursor).
    /// - Returns: A `TextState` with static characters removed and the cursor corrected.
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
                break // Ignore extra characters beyond the mask
            }
            
            let patternChar = patternChars[index]
            
            if patternChar.isPlaceholder {
                
                rawText.append(char)
                
                if index < cursorPosition {
                    rawCursorPosition += 1
                }
                
                rawIndex += 1
            } else {
                
                // Skip non-placeholder; if the cursor was beyond a static character,
                // shift it back to align with the unmasked content.
                if index < cursorPosition {
                    rawCursorPosition = rawIndex
                }
            }
        }
        
        return .init(rawText, cursorPosition: rawCursorPosition)
    }
    
    /// Converts a masked `NSRange` into the corresponding range in unmasked text.
    ///
    /// - If the `range.length` is zero, we return a zero-length unmasked range at `boundMap[loc].lower`.
    /// - Otherwise, we use `boundMap[start].lower` for the unmasked start,
    ///   and `boundMap[end-1].upper` for the unmasked end (exclusive).
    ///
    /// This approach allows single-character deletions at static positions
    /// to target the nearest placeholder instead of the static character.
    ///
    /// - Parameter range: The range in masked coordinates.
    /// - Returns: The equivalent range in unmasked coordinates.
    @usableFromInline
    func unmask(_ range: NSRange) -> NSRange {
        
        let count = patternChars.count
        guard count > 0 else { return range }
        
        // Zero-length => map location to `.lower` for an empty unmasked range.
        if range.length == 0 {
            let clampedLoc = min(range.location, count - 1)
            let lower = boundMap[clampedLoc].lower
            return NSRange(location: lower, length: 0)
        }
        
        // The masked range's start + end (exclusive).
        let maskedStart = range.location
        let maskedEnd   = range.location + range.length
        
        // Clamp both to [0, count].
        let s = max(0, min(maskedStart, count - 1))
        let e = max(s+1, min(maskedEnd, count)) // ensure e > s
        
        // Translate the start => .lower, and (end - 1) => .upper.
        let unmaskedStart = boundMap[s].lower
        let unmaskedEnd   = boundMap[e - 1].upper
        
        let length = max(0, unmaskedEnd - unmaskedStart)
        return NSRange(location: unmaskedStart, length: length)
    }
}

extension Character {
    
    /// Indicates if this character is a placeholder in the mask.
    ///
    /// Example placeholders might be `"N"` or `"_"`. Adjust as needed.
    @usableFromInline
    var isPlaceholder: Bool { self == "N" || self == "_" }
}

extension Array where Element == Character {
    
    /// Builds `(lower, upper)` for each character in `self`.
    ///
    /// - Placeholders each consume one unmasked index (e.g. `N` or `_`).
    ///   We store `(nextPlaceholderIndex, nextPlaceholderIndex+1)` then increment `nextPlaceholderIndex`.
    /// - Static characters do not advance the unmasked index. We store
    ///   `(lastPlaceholderIndex, lastPlaceholderIndex + 1)` so that
    ///   if a user deletes a static char, they effectively remove the preceding placeholder.
    ///
    /// This mapping is fundamental for single-character deletions that skip static characters
    /// and remove the intended placeholder in unmasked space.
    func buildBoundMap() -> [(Int, Int)] {
        
        var result: [(Int, Int)] = []
        result.reserveCapacity(count)
        
        var lastPlaceholderIndex = 0
        var nextPlaceholderIndex = 0
        
        for ch in self {
            
            if ch.isPlaceholder {
                
                // Each placeholder consumes one unmasked index
                result.append((nextPlaceholderIndex, nextPlaceholderIndex + 1))
                lastPlaceholderIndex = nextPlaceholderIndex
                nextPlaceholderIndex += 1
                
            } else {
                
                // Static char => allow single-char deletion to remove the prior placeholder
                let lower = lastPlaceholderIndex
                let upper = lastPlaceholderIndex + 1
                result.append((lower, upper))
            }
        }
        
        return result
    }
}

extension Mask {
    
    /// Filters out any characters in `text` disallowed by the mask pattern.
    ///
    /// This is a simplified approach that can be extended in `applyMask` for precise behavior.
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
    
    /// Checks if the mask is digits-only, typically recognized by `'N'` placeholders and no underscores.
    var isDigitsOnlyPattern: Bool {
        
        !contains("_") && contains("N")
    }
}
