//
//  PhoneNumberKitHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.12.2021.
//

import Foundation
import PhoneNumberKit

protocol PhoneNumberFormaterProtocol {
    func format(_ phoneNumber: String) -> String
}

struct PhoneNumberFormater: PhoneNumberFormaterProtocol {
    
    func format(_ phoneNumber: String) -> String {
        
        let phoneNumberKit = PhoneNumberKit()
        
        var returnValue = ""
        
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneNumber, ignoreType: true)
            returnValue = phoneNumberKit.format(phoneNumber, toType: .international)
        } catch {
            print("Something went wrong \(phoneNumber)")
        }
        
        return returnValue
    }
    
    func format(_ textField: PhoneNumberTextField) -> String {
        
        var returnValue = ""
        textField.becomeFirstResponder()
        
        textField.withExamplePlaceholder = true
        
        if !textField.withExamplePlaceholder {
            textField.placeholder = "Enter phone number"
        } else {
            returnValue = textField.text ?? ""
        }
        
        return returnValue
    }
    
}
