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
    
    private let phoneNumberKit = PhoneNumberKit()
    
    func format(_ phoneNumber: String) -> String {
        
        guard let phoneNumberParsed = try? phoneNumberKit.parse(phoneNumber, ignoreType: true)
        else { return phoneNumber }
                
        return phoneNumberKit.format(phoneNumberParsed, toType: .international)
    }
    
    //TODO: remove afrer refactoring
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


