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
    
    func shouldChangeCharacters(
        in range: NSRange,
        replacementString string: String,
        viewModel: AmountTextFieldViewModel
    ) -> Bool {
        
        guard let text = self.text else {
            return false
        }
        
        var temporary = text.filter { $0.isNumber }
        
        if string.isEmpty {
            if temporary.count > 0 {
                temporary.removeLast()
            }
            viewModel.value = Double(temporary) ?? 0
            return true
        }
        
        var filtered = "\(temporary)\(string)".filter { $0.isNumber }
        
        if filtered.count > 1 && filtered.first == "0" {
            filtered.removeFirst()
            viewModel.value = Double(filtered) ?? 0
            return false
        }
        
        guard let value = Double(filtered), value <= viewModel.bounds.upperBound else {
            return false
        }
        
        viewModel.value = value
        return false
    }
}
