//
//  ChangingReducer+mask.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

import Foundation
import TextFieldDomain

public extension ChangingReducer {
    
    /// Creates a `ChangingReducer` that applies a textual mask using the specified pattern.
    ///
    /// Steps:
    ///  1. Remove static characters from the current `textState`.
    ///  2. If the resulting unmasked text is empty and `replacementText` is also empty, returns `.empty`.
    ///  3. Convert the incoming masked `range` to unmasked coordinates using `Mask.unmask(_:)`.
    ///  4. Clean the `replacementText` (e.g., filter out disallowed chars).
    ///  5. Insert/rebuild the unmasked text, then re-apply the mask to produce the final masked result.
    ///
    /// - Parameters:
    ///   - placeholderText: Fallback text to show if masked input is empty.
    ///   - pattern: The string pattern describing placeholders and static characters.
    /// - Returns: A `ChangingReducer` that modifies text according to the provided mask.
    @inlinable
    static func mask(
        placeholderText: String,
        pattern: String
    ) -> Self {
        
        return ChangingReducer(
            placeholderText: placeholderText,
            change: { textState, replacementText, range in
                
                let mask = Mask(pattern: pattern)
                // 1. Remove static characters from the existing text state.
                let unmaskedTextState = mask.removeMask(from: textState)
                
                // 2. Early return with `.empty` if unmasked text is empty + user typed backspace (empty replacement).
                //    (Though strictly speaking, "delete" detection might need more nuance.)
                if unmaskedTextState.text.isEmpty && replacementText.isEmpty {
                    return .empty
                }
                
                // 3. Convert the masked `range` to unmasked coordinates.
                let unmaskedRange = mask.unmask(range)
                
                // 4. Remove any disallowed characters from `replacementText`.
                //    For example, only digits if the mask is for phone numbers.
                let cleanReplacementText = mask.clean(replacementText)
                
                // 5. Perform the replacement in unmasked text, then re-mask it.
                let replaced = try unmaskedTextState
                    .replace(inRange: unmaskedRange, with: cleanReplacementText)
                
                // 6. Return the final masked text state.
                let masked = mask.applyMask(to: replaced)
                
                return masked
            }
        )
    }
}
