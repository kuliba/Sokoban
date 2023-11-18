//
//  PhoneNumberKitHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.12.2021.
//

import Foundation
import PhoneNumberKit
import PhoneNumberWrapper

protocol PhoneNumberFormaterProtocol {
    
    func format(_ phoneNumber: String) -> String
    func partialFormatter(_ phoneNumber: String) -> String
    func isValid(_ phoneNumber: String) -> Bool
    func unformatted(_ phoneNumber: String) -> String
}

struct PhoneNumberKitFormater: PhoneNumberFormaterProtocol {
    
    private let phoneNumberKit = PhoneNumberKit()
    private let phoneNumberWrapper = PhoneNumberWrapper()
    
    func format(_ phoneNumber: String) -> String {
        
        return phoneNumberWrapper.format(phoneNumber)
    }
    
    func partialFormatter(_ phoneNumber: String) -> String {
        
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "RU")
        let phoneFormatted = partialFormatter.formatPartial(phoneNumber)
        
        return phoneFormatted
    }
    
    func isValid(_ phoneNumber: String) -> Bool {
        
        phoneNumberKit.isValidPhoneNumber(phoneNumber)
    }
    
    func unformatted(_ phoneNumber: String) -> String {
        
        phoneNumber.digits
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


