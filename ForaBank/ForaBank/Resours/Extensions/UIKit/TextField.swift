//
//  TextField.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.05.2022.
//

import UIKit

extension UITextField {

    func updateCursorPosition() {
        
        let arbitraryValue: Int = 2
        if let newPosition = position(from: endOfDocument, offset: -arbitraryValue) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
}
