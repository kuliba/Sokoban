//
//  AmountTextField.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 10.03.2025.
//

import SwiftUI
import UIKit

struct AmountTextField<InformerPayload>: UIViewRepresentable {

    let state: State
    let config: Config
    let event: (DomainEvent) -> Void

    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textColor = UIColor(config.calculator.desiredAmount.fontValue.foreground)
        textField.tintColor = UIColor(config.calculator.desiredAmount.fontValue.foreground)
        textField.backgroundColor = .clear
        textField.font = config.calculator.desiredAmount.textFieldFont
        textField.keyboardType = .numberPad
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.isUserInteractionEnabled = state.isAmountTextFieldFirstResponder
        uiView.text = state.formattedDesiredAmount
        uiView.updateCursorPosition()
        
        switch state.isAmountTextFieldFirstResponder {
        case true: uiView.becomeFirstResponder()
        case false: uiView.resignFirstResponder()
        }
    }
        
    func makeCoordinator() -> Coordinator {
        
        Coordinator(state: state, config: config, event: event)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let state: State
        let config: Config
        let event: (DomainEvent) -> Void

        public init(
            state: State,
            config: Config,
            event: @escaping (DomainEvent) -> Void
        ) {
            self.state = state
            self.config = config
            self.event = event
            super.init()
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.updateCursorPosition()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            guard let product = state.product else { return }
            
            let filtered = textField.text?.filter { $0.isNumber }
            
            guard let text = filtered, let value = UInt(text) else {
                
                textField.text = self.state.formattedDesiredAmount
                return
            }
            
            if value < product.calc.amount.minIntValue {
                
                event(.changeDesiredAmount(product.calc.amount.minIntValue))
            } else {
                
                let value = min(state.desiredAmount, product.calc.amount.maxIntValue)
                event(.changeDesiredAmount(value))
            }
            
            event(.setAmountResponder(false))
        }

        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            
            guard
                let text = textField.text,
                let product = state.product
            else { return false }
            
            var temporary = text.filter { $0.isNumber }
            
            if string.isEmpty {
                if temporary.count > 0 {
                    temporary.removeLast()
                }
                event(.changeDesiredAmount(UInt(temporary) ?? 0))
                return true
            }
            
            var filtered = text.replacingCharacters(in: Range(range, in: text)!, with: string).filter { $0.isNumber }
            
            if filtered.count > 1 && filtered.first == "0" {
                filtered.removeFirst()
                event(.changeDesiredAmount(UInt(filtered) ?? 0))
                return false
            }
            
            guard let value = UInt(filtered), value <= product.calc.amount.maxIntValue else {
                return false
            }
            
            event(.changeDesiredAmount(value))
            return false
        }
    }
}

extension AmountTextField {
    
    typealias Config = GetCollateralLandingConfig
    typealias DomainEvent = GetCollateralLandingDomain.Event<InformerPayload>
    typealias State = GetCollateralLandingDomain.State<InformerPayload>
}
