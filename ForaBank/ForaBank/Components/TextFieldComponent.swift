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
//
            //TODO: mask in init
            
            let masks = [StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16), StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)]
            
            guard let text = textField.text else {
                 return false
             }
            
            textField.text = TextFieldComponent.updateMasked(value: text, inRange: range, update: string, masks: masks, regExp: "[0-9]")
            
            return false
        }
    }
    
    struct StringValueMask: Equatable {
        
        let mask: String
        let symbol: String
        let len: Int
    }
    
    static func crop(value: String, max: Int) -> String {
        
        if value.digits.count > max{
            
            let cropValue = value.dropLast(value.digits.count - max)
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
        
        let filteredUpdate = filter(value: update, regEx: regExp)

        
        let start = value.index(value.startIndex, offsetBy: inRange.lowerBound)
        let end = value.index(value.startIndex, offsetBy: inRange.upperBound)
        
        var muttableValue = value
        muttableValue.replaceSubrange(start..<end, with: filteredUpdate)
        
        let filteredData = filter(value: muttableValue, regEx: regExp)
        
        let sortedMask = masks.sorted(by: { $0.len < $1.len })
        
        var maskedValue = ""
        
        for mask in sortedMask {
            
            if filteredData.count > mask.len, mask != masks.last{
                
                continue
            }
            
            maskedValue = maskValue(value: filteredData, mask: mask)
            
            break
        }
        
        return maskedValue

    }

    
}

