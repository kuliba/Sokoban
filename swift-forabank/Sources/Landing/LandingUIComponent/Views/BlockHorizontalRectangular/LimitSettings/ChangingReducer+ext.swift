//
//  ChangingReducer+ext.swift
//
//
//  Created by Andryusina Nataly on 12.08.2024.
//

import Foundation
import TextFieldModel

public extension ChangingReducer {

    static func decimal(
        formatter: DecimalFormatter,
        maxValue: Decimal
    ) -> Self {
        
        let change: ChangingReducer.Change = { textState, replacementText, range in
            
            // remove non-digits and repeating decimalSeparator from replacementText
            let hasDecimalSeparator = formatter.hasDecimalSeparator(textState.text)
            let replacementText = formatter.clean(
                text: replacementText,
                allowDecimalSeparator: !hasDecimalSeparator
            )
            
            // clamp range up to the space before currencySymbol
            let range = range.clamped(
                to: textState.text,
                droppingLast: 1 + formatter.currencySymbol.count
            )
            
            // memo cursor position from the end of text
            let cursorPositionFromEnd = textState.text.count - range.upperBound
            
            let changed = textState.text.shouldChangeTextIn(
                range: range,
                with: replacementText
            )
            
            let text = {
                if formatter.isDecimalSeparator(replacementText) {
                    return changed
                }
                
                // trailing zero after decimal separator
                let cleanText = formatter.clean(
                    text: textState.text,
                    allowDecimalSeparator: true
                )
                let isLastDecimalSeparator = {
                    
                    guard let last = cleanText.last else { return false }
                    
                    return formatter.isDecimalSeparator(.init(last))
                }()
                if replacementText == "0" && isLastDecimalSeparator {
                    return changed
                }
                
                let cleanChange = formatter.clean(
                    text: changed,
                    allowDecimalSeparator: true
                )
                let decimal = Decimal(
                    string: cleanChange,
                    locale: formatter.locale
                )
                                
                return formatter.format(min(decimal ?? 0, maxValue)) ?? ""
            }()
            
            let cursorPosition = text.count - cursorPositionFromEnd
            
            return .init(
                text,
                cursorPosition: max(0, cursorPosition)
            )
        }
        
        return .init(placeholderText: "", change: change)
    }
}
