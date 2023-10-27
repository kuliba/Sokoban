//
//  PhoneNumberKitWrapper.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

import PhoneNumberKit
import PhoneNumberWrapper

enum PhoneNumberKitWrapper {
    
    private static let phoneNumberKit = PhoneNumberKit()
    private static let phoneNumberWrapper = PhoneNumberWrapper()
    
    private static var partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit)
    
    static func isValidPhoneNumber(_ input: String) -> Bool {
     
        phoneNumberKit.isValidPhoneNumber(input)
    }
    
    static func formatPartial(
        for type: ContactsViewModel.PaymentsType,
        _ input: String
    ) -> String {
        
        switch type {
        case .abroad:
            return partialFormatter.formatPartial(input)
        default:
            return phoneNumberWrapper.format(input)
        }
    }
}
