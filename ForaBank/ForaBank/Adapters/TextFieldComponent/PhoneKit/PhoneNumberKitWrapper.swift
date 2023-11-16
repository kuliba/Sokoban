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
    
    private static var partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "RU")
    
    static func isValidPhoneNumber(_ input: String) -> Bool {
     
        phoneNumberKit.isValidPhoneNumber(input)
    }
    
    static func formatPartial(
        _ input: String
    ) -> String {
        return phoneNumberWrapper.format(input)
    }
}
