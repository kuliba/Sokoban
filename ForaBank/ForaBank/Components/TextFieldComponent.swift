//
//  TextFieldComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 16.02.2022.
//

import Foundation
import SwiftUI

struct TextFieldComponent: UIViewRepresentable {
    
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
            return true
        }
    }
    
    struct StringValueMask {
        
        let mask: String
        let symbol: String
    }
    
    static func filter(value: String) -> String {
        
        return  value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    static func crop(value: String, max: Int) -> String {
        
        if value.count > max{
            
            let cropValue = value.dropLast( value.count - max)
            return String(cropValue)
        }
        
        return value
    }
    
    static func maskValue(value: String, mask: StringValueMask) -> String {

        var formattedString = ""
        var currentMaskIndex = 0
        
        for i in 0..<value.count {
            
            if currentMaskIndex >= mask.mask.count {
                return formattedString
            }
            
            let currentCharacter = value[value.index(value.startIndex, offsetBy: i)]
            var maskCharacter = mask.mask[mask.mask.index(value.startIndex, offsetBy: currentMaskIndex)]
            
            if currentCharacter == maskCharacter {
                
                formattedString.append(currentCharacter)
            } else {
                
                while maskCharacter != mask.symbol.first {
    
                    formattedString.append(maskCharacter)
                    currentMaskIndex += 1
                    maskCharacter = mask.mask[mask.mask.index(value.startIndex, offsetBy: currentMaskIndex)]
                }
                formattedString.append(currentCharacter)
            }
            
            currentMaskIndex += 1
        }
        
        return formattedString
    }
    
    static func unmask(value: String, regEx: String) -> String? {
        
        do{
            
            let regExp = try NSRegularExpression(pattern: regEx, options: [])
            let range = NSMakeRange(0, value.count)
            let results = regExp.matches(in: value, options: [], range: range)

            var resultValue = ""
            for res in results {
                
                resultValue += (value as NSString).substring(with: res.range)
            }

            return resultValue
        } catch {
            
            print("Regular Expressions error")
            return nil
        }
    }
    
}

