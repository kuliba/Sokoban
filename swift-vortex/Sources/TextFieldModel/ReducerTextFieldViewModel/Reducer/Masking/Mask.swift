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
    
    // For each masked index i, store:
    //   boundMap[i].lower => the unmasked index if i is the start of a range
    //   boundMap[i].upper => the unmasked index if i is the *end* (exclusive)
    @usableFromInline
    let boundMap: [(lower: Int, upper: Int)]
    
    @usableFromInline
    init(pattern: String) {
        
        self.pattern = pattern
        self.patternChars = Array(pattern)
        
        self.boundMap = Array(pattern).buildBoundMap()
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
    
    @usableFromInline
    func unmask(
        _ range: NSRange
    ) -> NSRange {
        
        // If empty, short-circuit or map to zero-length:
        if range.length == 0 {
            let loc = min(range.location, boundMap.count - 1)
            let start = boundMap[loc].lower
            return NSRange(location: start, length: 0)
        }
        
        // The masked start
        let maskedStart = range.location
        // The masked end (exclusive)
        let maskedEnd   = range.location + range.length
        
        // Clamp them
        let s = max(0, min(maskedStart, boundMap.count - 1))
        let e = max(s+1, min(maskedEnd, boundMap.count))
        
        // Lower bound uses `boundMap[s].lower`
        let startUnmasked = boundMap[s].lower
        
        // Upper bound uses `boundMap[e - 1].upper`
        let endUnmasked   = boundMap[e - 1].upper
        
        let length = max(0, endUnmasked - startUnmasked)
        return .init(location: startUnmasked, length: length)
    }
}

extension Array where Element == Character {
    
    /// Builds a bound map for each mask index i -> (lower, upper).
    /// - lower: unmasked index if used as start of the range
    /// - upper: unmasked index if used as end (exclusive)
    ///
    func buildBoundMap() -> [(lower: Int, upper: Int)] {
        
        var result: [(lower: Int, upper: Int)] = []
        result.reserveCapacity(count)
        
        var lastPlaceholderIndex = 0   // track the *last used* unmasked index
        var nextPlaceholderIndex = 0   // track how many placeholders we've seen so far
        
        for ch in self {
            
            if ch.isPlaceholder {
                
                // This character consumes one unmasked slot
                // lower bound is nextPlaceholderIndex
                // upper bound is nextPlaceholderIndex+1
                result.append((lower: nextPlaceholderIndex, upper: nextPlaceholderIndex + 1))
                
                lastPlaceholderIndex = nextPlaceholderIndex
                nextPlaceholderIndex += 1
                
            } else {
                
                // Static character:
                // For the *start* of a range, we probably want to *stay* at lastPlaceholderIndex
                // (so if we pick masked index of a dash, we interpret it as "start" = the last placeholder)
                //
                // For the *end* of a range, we might want to “include” that placeholder if used as an exclusive bound
                // so we do upper = lastPlaceholderIndex + 1
                // This ensures that if dash is used as an upper bound, it effectively deletes the previous placeholder.
                
                // Tweak logic based on your exact desired deletion behavior:
                let lower = lastPlaceholderIndex
                let upper = lastPlaceholderIndex    // naive approach: no shift if used as end
                
                // Alternatively, if you want "dash" to remove the preceding placeholder, do:
                // let upper = lastPlaceholderIndex + 1
                
                result.append((lower, upper))
            }
        }
        
        return result
    }
    
    /// Builds a precise mapping using `chunkify()` to map masked indices to unmasked index ranges.
    ///
    /// Fully leverages `chunkify()` for accurate (lower, upper) range mapping.
    @inlinable
    func buildMapping() -> [(lower: Int, upper: Int)] {
        
        // Step 1: Generate the mask map where placeholders are mapped to indices, and statics are `-1`
        let maskMapping = generateMaskMap()
        
        // Step 2: Chunkify the map to group static characters with the nearest placeholder
        let chunkified = maskMapping.chunkify()
        
        // Step 3: Directly use the chunkified map to build (lower, upper) ranges
        return maskMapping.enumerated().map { (index, value) in
            if let upperBound = chunkified[value] {
                return (value, upperBound + 1)
            } else {
                return (value, value)
            }
        }
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
