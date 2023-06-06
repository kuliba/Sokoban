//
//  PhoneNumberKitWrapper.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

import PhoneNumberKit

enum PhoneNumberKitWrapper {
    
    private static let phoneNumberKit = PhoneNumberKit()
    
    private static var partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit)
    
    static func isValidPhoneNumber(_ input: String) -> Bool {
     
        phoneNumberKit.isValidPhoneNumber(input)
    }
    
    static func formatPartial(_ input: String) -> String {
        
        partialFormatter.formatPartial(input)
    }
}
