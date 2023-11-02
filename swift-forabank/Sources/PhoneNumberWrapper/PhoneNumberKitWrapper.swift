//
//  PhoneNumberWrapper.swift
//
//
//  Created by Andryusina Nataly on 18.10.2023.
//

import PhoneNumberKit
import Foundation

public struct PhoneNumberWrapper {
    
    private let phoneNumberKit: PhoneNumberKit
    private let defaultRegionCode = PhoneNumberKit.defaultRegionCode()

    public func isValidPhoneNumber(_ input: String) -> Bool {
        
        phoneNumberKit.isValidPhoneNumber(input)
    }
    
    public init(
        _ phoneNumberKit: PhoneNumberKit = PhoneNumberKit()
    ) {
        self.phoneNumberKit = phoneNumberKit
    }
    
    public func format(_ value: String) -> String {
        
        let phoneNumber = addCodeRuIfNeeded(value.onlyDigits().changeCodeIfNeeded())
        let regionCode = phoneNumberKit.codeBy(phoneNumber)
        let codeLength = countryCodeLength(by: regionCode)
        
        guard let phoneNumberParsed = try? codeLength > 0 ?
                phoneNumberKit.parse(
                    String(phoneNumber.dropFirst(codeLength)),
                    withRegion: regionCode ?? defaultRegionCode,
                    ignoreType: true) :
                    phoneNumberKit.parse(
                        phoneNumber,
                        ignoreType: true)
                
        else { return phoneNumber.applyPatternOnPhoneNumber() }
        return phoneNumberKit.format(phoneNumberParsed, toType: .international)
    }
    
    private func formatWithRegion(
        _ phoneNumber: String
    ) -> String {
        
        guard let region = regionByPhone(phoneNumber), let phoneNumbersCustomDefaultRegion = try? phoneNumberKit.parse(
            phoneNumber,
            withRegion: region,
            ignoreType: true
        ) else { return phoneNumber.applyPatternOnPhoneNumber() }
        return phoneNumberKit.format(
            phoneNumbersCustomDefaultRegion,
            toType: .international)
    }
    
    private func regionByPhone(_ input: String) -> String? {
        
        if (input.hasPrefix(.nationalDigitalCodeRu) &&
            input.count == .phoneNumberWithCodeLengthRU) ||
            input.count == .phoneNumberWithoutCodeLengthRU {
            return .countryCodeRu
        }
        
        return nil
    }
    
    private func addCodeRuIfNeeded(_ input: String) -> String {
        return input.hasPrefix("89") ? "79" + input.dropFirst(2) : input
    }
    
    func countryCodeLength(by code: String?) -> Int {
        guard let code else { return 0 }
        return phoneNumberKit.countryCode(for: code)?.countDigits ?? 0
     }
}

private extension Int {
    static let phoneNumberWithCodeLengthRU: Self = 11
    static let phoneNumberWithoutCodeLengthRU: Self = 10
}

private extension String {
    static let countryCodeRu: Self = "RU"
    static let nationalDigitalCodeRu: Self = "8"
}

extension UInt64 {
    var countDigits: Int {
        return String(describing: self).count
    }
}

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
