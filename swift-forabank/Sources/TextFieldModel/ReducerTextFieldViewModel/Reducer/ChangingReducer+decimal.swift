//
//  ChangingReducer+decimal.swift
//  
//
//  Created by Igor Malyarov on 15.12.2023.
//

import Foundation
import TextFieldDomain

public extension ChangingReducer {

    static func decimal(
        formatter: DecimalFormatter
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
                } else {
                    let filtered = formatter.clean(
                        text: changed,
                        allowDecimalSeparator: true
                    )
                    let decimal = Decimal(
                        string: filtered,
                        locale: formatter.locale
                    )
                    
                    return formatter.format(decimal ?? 0) ?? ""
                }
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
