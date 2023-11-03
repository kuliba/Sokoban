//
//  PhoneNumberKit+Ext.swift
//
//
//  Created by Andryusina Nataly on 03.11.2023.
//

import Foundation
import PhoneNumberKit

extension PhoneNumberKit {
    
    var allCountryCodes: [UInt64] {
        allCountries().compactMap(countryCode(for:))
    }
    
    func codeBy(_ number: String) -> String? {
        
        for countryCode in allCountryCodes {
            // Check if number starts with country code
            if number =~ "^\\+?\(countryCode).*" {
                return mainCountry(forCode: countryCode)
            }
        }
        return nil
    }
}

infix operator =~
func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern)?.test(input) ?? false
}

final class Regex {
    
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init?(_ pattern: String) {
        if let internalExpression = try? NSRegularExpression(
            pattern: pattern,
            options: .caseInsensitive
        ) {
            self.internalExpression = internalExpression
            self.pattern = pattern
        } else {
            return nil
        }
    }
    
    func test(_ input: String) -> Bool {
        let matches = internalExpression.matches(
            in: input,
            options: .anchored,
            range: NSRange(location: 0, length: input.count)
        )
        return matches.count > 0
    }
}
