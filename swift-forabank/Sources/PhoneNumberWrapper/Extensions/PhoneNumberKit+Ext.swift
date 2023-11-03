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
        return allCountries().compactMap {
            return countryCode(for: $0)
        }
    }
    
    func codeBy(_ number: String) -> String? {
        
        for countryCode in allCountryCodes {
        // Check if number starts with country code
            if number =~ "^\\+?\(countryCode).*" {
                return self.mainCountry(forCode: countryCode)
            }
        }
        return nil
    }
}

infix operator =~
func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern)?.test(input) ?? false
}

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init?(_ pattern: String) {
        self.pattern = pattern
        if let internalExpression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            self.internalExpression = internalExpression
        } else {
            return nil
        }
    }
    
    func test(_ input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: .anchored, range: NSRange(location: 0, length: input.count))
        return matches.count > 0
    }
}
