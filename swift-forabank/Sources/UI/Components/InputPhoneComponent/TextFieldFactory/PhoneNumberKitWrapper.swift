//
//  PhoneNumberKitWrapper.swift
//  
//
//  Created by Дмитрий Савушкин on 06.03.2024.
//

import TextFieldComponent
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

extension Transformers {
    
    static func phoneKit(
        filterSymbols: [Character],
        substitutions: [CountryCodeSubstitution],
        limit: Int? = 18
    ) -> Transform {
        
        phone(
            filterSymbols: filterSymbols,
            substitutions: substitutions,
            format: {
                
                guard !$0.isEmpty else { return $0 }
                
                return PhoneNumberKitWrapper.formatPartial(!$0.hasPrefix("+") ? "+\($0)" : $0)
            },
            limit: limit
        )
    }
}
