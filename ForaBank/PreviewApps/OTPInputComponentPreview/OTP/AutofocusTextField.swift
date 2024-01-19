//
//  AutofocusTextField.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI
import UIKit

struct AutofocusTextField: UIViewRepresentable {
    
    let placeholder: String
    @Binding var text: String
    var isFirstResponder: Bool = false
    let keyboardType: UIKeyboardType

    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.delegate = context.coordinator
        
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = text
        
        if isFirstResponder {
            
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        
        return Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        
        var parent: AutofocusTextField

        init(_ textField: AutofocusTextField) {
            
            self.parent = textField
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            
            parent.text = textField.text ?? ""
        }
    }
}
