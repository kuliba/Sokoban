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
    func partialFormatter(_ phoneNumber: String) -> String
    func isValid(_ phoneNumber: String) -> Bool
}

struct PhoneNumberKitFormater: PhoneNumberFormaterProtocol {
    
    private let phoneNumberKit = PhoneNumberKit()
    
    func format(_ phoneNumber: String) -> String {
        
        guard let phoneNumberParsed = try? phoneNumberKit.parse(phoneNumber, ignoreType: true)
        else { return phoneNumber }
                
        return phoneNumberKit.format(phoneNumberParsed, toType: .international)
    }
    
    func partialFormatter(_ phoneNumber: String) -> String {
        
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit)
        let phoneFormatted = partialFormatter.formatPartial(phoneNumber)
        
        return phoneFormatted
    }
    
    func isValid(_ phoneNumber: String) -> Bool {
        
        let phoneNumberParsed = phoneNumberKit.isValidPhoneNumber(phoneNumber)
        return phoneNumberParsed
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


