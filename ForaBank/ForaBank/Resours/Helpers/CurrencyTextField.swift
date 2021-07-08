//
//  CurrencyTextField.swift
//  ForaBank
//
//  Created by Mikhail on 07.07.2021.
//

import UIKit

class CurrencyTextField: UITextField {
    
    var maxLength = 20
    
    override var intrinsicContentSize: CGSize {
            let parentSize = super.intrinsicContentSize
            //calculate min size, to prevent  changing width of field lower than this
        var minSize = (String(repeating: "0", count: 20) as NSString).size(withAttributes: [NSAttributedString.Key.font: font as Any])
            minSize.height = parentSize.height

            if isEditing {
                if let text = text,
                    !text.isEmpty {
                    // Convert to NSString to use size(attributes:)
                    let string = text as NSString
                    // Calculate size for current text
                    var returnSize = string.size(withAttributes: typingAttributes)
                    // Add margin to calculated size
                    returnSize.width += 10
                    returnSize.height = parentSize.height
                    return returnSize.width >  minSize.width ? returnSize : minSize
                } else {
                    // You can return some custom size in case of empty string
                    return parentSize
                }
            } else {
                if let text = text,
                    !text.isEmpty {
                    var returnSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font as Any] )
                    returnSize.width += 10
                    returnSize.height = parentSize.height
                    return returnSize.width >  minSize.width ?  returnSize :  minSize
                }
                return parentSize
            }
            return parentSize
        }
    
}
