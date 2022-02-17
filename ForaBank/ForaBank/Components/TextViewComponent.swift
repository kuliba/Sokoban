//
//  TextViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 16.02.2022.
//

import Foundation
import SwiftUI

// 1 enter "2"
// 2 unmask "1234 567" -> "1234567"
// 3 "1234567" + "2" = "12345672" & crop (<= 20)
// 4 mask -> "1234 5672"

// 1 enter ""
// 2 unmask "1234 567" -> "1234567"
// 3 "1234567" - "7" = "123456" & crop (>=0)
// 4 mask -> "1234 567"

// 1 filter & crop "4565 kls l;k" -> "4565" (<= 20) range > 1
// 2 "1234 567" -> "234 5"
// 3 unmask "1234 567" -> "1234567"
// 4 remove " " "234 5" -> "2345"
// 5 range "1234567" for "2345"
// 6 insert  "4565" in range "1234567" ->  "1456567"
// 7 crop to 20
// 8 mask -> "1456 567"

// static func filter(value: String) -> String  ///"4565 kls l;k" -> "4565"
// static func crop(value: String, max: Int) -> String // max = 5: "1234567" -> "12345" ; "12" -> "12"

// static func mask(value: String, mask: StringValueMask) -> String
// mask(value: "12345", mask: "### ###", symbol: "#") -> String

// static func unmask(value: String, regEx: String) -> String ; "123 45" -> "12345"

// static func updateMasked(value: String, inRange: Range, update: String, masks: [StringValueMask], regEx: String) -> String

struct StringValueMask {
    
    let mask: String //"### ###"
    let sympol: String //"#"
    let len: Int // 16
}

// let mask = StringMask(mask: "#### ####", symbol: "#", len: 16)

struct TextView: UIViewRepresentable {
    
    @Binding var text: String
    @State var isValidate: Bool
    
    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField()
        
        textField.delegate = context.coordinator
        textField.isUserInteractionEnabled = true
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.tintColor = .white
        textField.font = .systemFont(ofSize: 20)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = text
    }
    
    func makeCoordinator() -> CoordinatorField {
        
        CoordinatorField($text)
    }
    
    class CoordinatorField: NSObject, UITextFieldDelegate {
        
        var text: Binding<String>
        
        init(_ text: Binding<String>) {
            
            self.text = text
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            guard let currentText: NSString = textField.text as NSString? else { return false}
            
            var mask: StringMask?
            let newText = currentText.replacingCharacters(in: range, with: string)
            
            let valid = NumberValidator.init(newText.digits).isValid
            print(valid)
            
            if newText.digits.count <= 16 {
                
                mask = StringMask(mask: "0000 0000 0000 0000")
            } else {
                
                mask = StringMask(mask: "00000 0 000 0000 0000000")
            }
            guard let mask = mask else { return false }
            
            var formattedString = mask.mask(string: String(newText.digits.prefix(20)))
            
            if formattedString == nil {
                
                let unmaskedString = mask.unmask(string: newText)
                formattedString = mask.mask(string: unmaskedString)
            }
            
            guard let finalText = formattedString as NSString? else { return false }
            
            if finalText == currentText && range.location < currentText.length && range.location > 0 {
                return self.textField(textField, shouldChangeCharactersIn: NSRange(location: range.location - 1, length: range.length + 1) , replacementString: string)
            }
            
            if finalText != currentText {
                textField.text = finalText as String
                
                if range.location < currentText.length {
                    var cursorLocation = 0
                    
                    if range.location > finalText.length {
                        cursorLocation = finalText.length
                    } else if currentText.length > finalText.length {
                        cursorLocation = range.location
                    } else {
                        cursorLocation = range.location + 1
                    }
                    guard let startPosition = textField.position(from: textField.beginningOfDocument, offset: cursorLocation) else { return false }
                    guard let endPosition = textField.position(from: startPosition, offset: 0) else { return false }
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: endPosition)
                }
                return false
            }
            return true
        }
    }
    
    public enum NumberType: String {
        
        case card =  "^4[0-9]{6,}$"
        case account = "[0-9]$"
        
        var validNumberLength: IndexSet {
            switch self {
            case .card:
                return IndexSet(integer: 16)
            case .account:
                return IndexSet(integer: 20)
            }
        }
    }
    
    public struct NumberValidator {
        
        private let types: [NumberType] = [
            .card,
            .account
        ]
        
        private let string: String
        
        public init(_ string: String) {
            self.string = string.digits
        }
        
        public var type: NumberType? {
            types.first { type in
                NSPredicate(format: "SELF MATCHES %@", type.rawValue)
                    .evaluate(
                        with: string.digits
                    )
            }
        }
        
        public var isValid: Bool {
            guard let type = type else { return false }
            let isValidLength = type.validNumberLength.contains(string.count)
            return isValidLength
        }
        
        public func isValid(for type: NumberType) -> Bool {
            isValid && self.type == type
        }
    }
}

