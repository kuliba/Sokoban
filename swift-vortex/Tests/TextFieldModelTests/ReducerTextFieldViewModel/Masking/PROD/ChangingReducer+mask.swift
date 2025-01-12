//
//  ChangingReducer+mask.swift
//
//
//  Created by Igor Malyarov on 11.01.2025.
//

import Foundation
import TextFieldDomain
import TextFieldModel

#warning("add documentation")
public extension ChangingReducer {
    
    /// Create `ChangingReducer` with ____________________________.
    @inlinable
    static func mask(
        placeholderText: String,
        pattern: String
    ) -> Self {
        
        return ChangingReducer(
            placeholderText: placeholderText,
            change: { textState, replacementText, range in
                
                let mask = Mask(pattern: pattern)
                // 1. de-mask textState
                let unmaskedTextState = mask.removeMask(from: textState)
                // 2. early return with `.empty` if de-masked textState is empty and replacement is `delete`
                #warning("below is not exactly `replacement is `delete``")
                if unmaskedTextState.text.isEmpty && replacementText.isEmpty {
                    return .empty
                }
                // 3. de-mask range
                let unmaskedRange = mask.unmask(range)
                // 4. cleanup replacementText - remove characters that are not allowed by mask pattern - this is over-simplified (precise should be done in `applyMask`) but could work for `digits-only` masks
                let cleanReplacementText = mask.clean(replacementText)
                // 5. transform de-masked textState with de-masked range and cleaned replacementText
                let replaced = try unmaskedTextState
                    .replace(inRange: unmaskedRange, with: cleanReplacementText)
                // 6. mask transformed textState
                let masked = mask.applyMask(to: replaced)
                
                return masked
            }
        )
    }
}
