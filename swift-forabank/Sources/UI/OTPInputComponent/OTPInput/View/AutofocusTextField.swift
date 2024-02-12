//
//  AutofocusTextField.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI
import UIKit

struct AutofocusTextField: UIViewRepresentable {
    
    let placeholder: String
    @Binding var text: String
    var isFirstResponder: Bool = false
    let textColor: UIColor
    let backgroundColor: UIColor
    let keyboardType: UIKeyboardType
    
    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.textColor = textColor
        textField.backgroundColor = backgroundColor
        textField.delegate = context.coordinator
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            context.coordinator.didBecomeFirstResponder = true
        }
        
        return textField
    }
    
    // TODO: fix keyboard hangs
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        if uiView.text != text {
            
            uiView.text = text
        }
        
        if isFirstResponder && !uiView.isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            
            DispatchQueue.main.async {
                
                uiView.becomeFirstResponder()
                context.coordinator.didBecomeFirstResponder = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var parent: AutofocusTextField
        var didBecomeFirstResponder = false
        
        init(_ textField: AutofocusTextField) {
            
            self.parent = textField
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            
            parent.text = textField.text ?? ""
        }
    }
}

private extension UIView {
    
    var subviewFirstPossibleResponder: UIView? {
        
        guard !canBecomeFirstResponder else { return self }
        
        for subview in subviews {
            
            if let firstResponder = subview.subviewFirstPossibleResponder {
                
                return firstResponder
            }
        }
        
        return nil
    }
}
