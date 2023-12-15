//
//  ChangingReducer+decimal.swift
//  
//
//  Created by Igor Malyarov on 15.12.2023.
//

import Foundation
import TextFieldComponent

public extension ChangingReducer {

    static func decimal(
        currencySymbol: String = "₽",
        locale: Locale = .current
    ) -> Self {
        
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol,
            locale: locale
        )
        let change: ChangingReducer.Change = { textState, replacementText, range in
            
            // remove non-digits and repeating decimalSeparator from replacementText
            let hasDecimalSeparator = formatter.hasDecimalSeparator(textState.text)
            let replacementText = formatter.filter(
                text: replacementText,
                allowDecimalSeparator: !hasDecimalSeparator
            )
            
            // clamp range up to the space before currencySymbol
            let range = range.clamped(
                to: textState.text,
                droppingLast: 1 + currencySymbol.count
            )
            
            // memo cursor position from the end of text
            let cursorPositionFromEnd = textState.text.count - range.upperBound
            
            let changed = textState.text.shouldChangeTextIn(
                range: range,
                with: replacementText
            )
            let d = formatter.filter(
                text: changed, 
                allowDecimalSeparator: true
            )
            let decimal = Decimal(string: d, locale: locale) ?? 0
            let text = formatter.format(decimal) ?? ""
            let cursorPosition = text.count - cursorPositionFromEnd
            
            return .init(
                text,
                cursorPosition: max(0, cursorPosition)
            )
        }
        
        return .init(placeholderText: "", change: change)
    }
}
