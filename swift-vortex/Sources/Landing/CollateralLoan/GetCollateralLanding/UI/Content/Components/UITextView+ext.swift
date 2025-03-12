//
//  UITextView+ext.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 11.03.2025.
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
