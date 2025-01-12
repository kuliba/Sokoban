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
        
        // Build the boundMap by counting placeholders
        // 'lower' uses the current unmasked index
        // 'upper' uses unmasked index + 1 for placeholders
        // static chars keep the same unmasked index for lower & upper
        var map: [(lower: Int, upper: Int)] = []
        map.reserveCapacity(patternChars.count)
        
        var unmaskedIndex = 0
        
        for ch in patternChars {
            if ch.isPlaceholder {
                // E.g. 'N' or '_'
                map.append((lower: unmaskedIndex, upper: unmaskedIndex + 1))
                unmaskedIndex += 1
            } else {
                // Static char => both bounds are the *same*
                map.append((lower: unmaskedIndex, upper: unmaskedIndex))
            }
        }
        
        self.boundMap = map
    }
    
    /// Translates an NSRange in the *masked* text to the corresponding range in the *unmasked* text,
    /// using the distinct lower/upper bounds in `boundMap`.
    @usableFromInline
    func unmask(_ range: NSRange) -> NSRange {
        
        guard !patternChars.isEmpty else { return range }
        
        let maxMaskedIndex = patternChars.count // One past the last valid index
        
        // 1) Zero-length => map location to 'lower' and produce zero-length
        if range.length == 0 {
            let clampedLoc = min(range.location, maxMaskedIndex - 1)
            let mappedLoc = boundMap[clampedLoc].lower
            return NSRange(location: mappedLoc, length: 0)
        }
        
        // 2) Compute the masked start and end
        //    Masked end = location + length (exclusive)
        let maskedStart = range.location
        let maskedEnd   = range.location + range.length
        
        // 3) Clamp them
        let clampedStart = max(0, min(maskedStart, maxMaskedIndex - 1))
        let clampedEnd   = max(clampedStart + 1, min(maskedEnd, maxMaskedIndex))
        // We do `+1` on clampedStart if we're ensuring we never do an empty end below it.
        // (But at least we want end > start)
        
        // 4) Translate:
        //    - The start => use 'lower'
        //    - The end   => use 'upper', but note it’s exclusive, so index is (clampedEnd - 1)
        let startUnmasked = boundMap[clampedStart].lower
        
        // If clampedEnd is exactly patternChars.count, then we do (clampedEnd - 1) = last valid index
        let endIndex = clampedEnd - 1 // safe, because clampedEnd ≤ maxMaskedIndex
        let endUnmasked   = boundMap[endIndex].upper
        
        // 5) Build the unmasked range
        let length = max(0, endUnmasked - startUnmasked)
        return NSRange(location: startUnmasked, length: length)
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

extension Array where Element == Character {
    
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
