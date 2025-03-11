//
//  AmountTextField.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 10.03.2025.
//

import SwiftUI
import UIKit

struct AmountTextField: UIViewRepresentable {
    
    var viewModel: AmountTextFieldViewModel
    
    init(viewModel: AmountTextFieldViewModel) {
        
        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textColor = UIColor(Color.white) // TODO: Place on config
        textField.tintColor = UIColor(Color.gray)  // TODO: Place on config
        textField.backgroundColor = .clear
        textField.font = UIFont(name: "Inter-SemiBold", size: 24)
        textField.keyboardType = .numberPad
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.isUserInteractionEnabled = viewModel.isFirstResponder
        uiView.text = viewModel.valueCurrencySymbol
        uiView.updateCursorPosition()
        
        switch viewModel.isFirstResponder {
        case true: uiView.becomeFirstResponder()
        case false: uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let viewModel: AmountTextFieldViewModel
        
        init(viewModel: AmountTextFieldViewModel) {
            
            self.viewModel = viewModel
            super.init()
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.updateCursorPosition()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            viewModel.textFieldDidEndEditing(textField)
        }
        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            
            textField.shouldChangeCharacters(
                in: range,
                replacementString: string,
                viewModel: viewModel
            )
        }
    }
}
