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
            
            let mask = [StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16), StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)]
            
            guard let text = textField.text else {
                return false
            }
   
                let cleanString = filter(value: string, regEx: "[0-9]")
            
                let croppedString = crop(value: cleanString, max: mask[1].mask.count - text.count)
            
                let updateMasked = updateMasked(value: text, inRange: range, update: croppedString, masks: mask, regExp: "[0-9]")
                
                textField.text = updateMasked
            
            return false
        }
    }
    
    struct StringValueMask {
        
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

        var maskType = StringValueMask(mask: "#### #### #### ####", symbol: "#", len: 16)
        
        if value.digits.count + update.digits.count > 16{
            
            maskType = StringValueMask(mask: "##### # ### #### #######", symbol: "#", len: 20)
        }
        
        
        
        if update == "" {
            
            let filterNumber = filter(value: value, regEx: "[0-9]")
            let maxIndex =  filterNumber.index(filterNumber.startIndex, offsetBy: filterNumber.count - 1)
            let number = String(filterNumber[filterNumber.startIndex..<maxIndex])
            
            let maskNumber = maskValue(value: number, mask: maskType)
            
            return maskNumber
            
        }
        
        if inRange.length > 1{
            
            let filteredValue = filter(value: value, regEx: "[0-9]")
            let filteredUpdate = filter(value: update, regEx: "[0-9]")
            
            
            let croppedUpdate = crop(value: filteredUpdate, max: 20 - filteredValue.digits.count)
        
            if croppedUpdate.count > 1{

                let start = value.index(value.startIndex, offsetBy: inRange.lowerBound)
                let end = value.index(value.startIndex, offsetBy: inRange.upperBound)
                
                var data = value
                data.replaceSubrange(start..<end, with: filteredUpdate)
                
                let filteredData = filter(value: data, regEx: "[0-9]")
                
                let maskNumber = maskValue(value: filteredData, mask: maskType)
                print(maskNumber)
                return maskNumber
            } else {
                
                return value
            }
        } else if inRange.lowerBound == inRange.upperBound {
            
            if inRange.location < value.count{
                
                var data = value
                
                let croppedNum = crop(value: update, max: 20 - value.digits.count)
                let index = data.index(data.startIndex, offsetBy: inRange.location)
                data.insert(contentsOf: croppedNum, at: index)
                let maskNumber = maskValue(value: data, mask: maskType)
                
                return maskNumber
            } else {
                
                let filteredValue = filter(value: value, regEx: "[0-9]")

                let updateNumber = filteredValue + update
                let croppedNum = crop(value: updateNumber, max: 20)
                let maskNumber = maskValue(value: croppedNum, mask: maskType)
                
                return maskNumber
            }
        }
        
        
        return value
    }

    
}

