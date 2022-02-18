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
            
            let mask = [StringValueMask(mask: "#### #### #### ####", symbol: "#"), StringValueMask(mask: "##### # ### #### #######", symbol: "#")]
            
            guard let text = textField.text else {
                return false
            }
            
                let cleanString = filter(value: string, regEx: "[0-9]")
            
                let croppedString = crop(value: cleanString, max: mask[1].mask.count - text.count)
                let updateMasked = updateMasked(value: text, inRange: range, update: croppedString, masks: mask, regExp: "[0-9]")
                
                if updateMasked.digits.count <= 16{
                    
                    textField.text = maskValue(value: updateMasked, mask: mask[0])
                } else {
                    
                    textField.text = maskValue(value: updateMasked, mask: mask[1])
                }
            
            return false
        }
    }
    
    struct StringValueMask {
        
        let mask: String
        let symbol: String
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
    
    static func filter(value: String, regEx: String) -> String {
        
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
            return ""
        }
    }
    
    static func updateMasked(value: String, inRange: NSRange, update: String,  masks: [StringValueMask], regExp: String) -> String {
        
        
        
        if inRange.length == 1{
            
            let maxIndex =  value.index(value.startIndex, offsetBy: value.count - 1)
            let number = String(value[value.startIndex..<maxIndex])
            let filteredNumber = filter(value: number, regEx: "[0-9]")
            
            return filteredNumber
        }
        
        if inRange.lowerBound == inRange.upperBound, let textRange = Range(inRange, in: value) {
                    
                    let updatedText = value.replacingCharacters(in: textRange, with: update)
                
                    return updatedText
            
        } else if inRange.lowerBound < inRange.upperBound {

            let updatedText = value.replacingOccurrences(of: value, with: update, options: [], range: .init(.init(location: inRange.location, length: inRange.length), in: value + update))
 
            return updatedText
        }
        
        return ""
    }

    
}

