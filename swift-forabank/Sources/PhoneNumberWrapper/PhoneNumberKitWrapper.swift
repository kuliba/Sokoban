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
        let countryCode = phoneNumberKit.codeBy(phoneNumber)
        let codeLength = countryCodeLength(by: countryCode)
        let mask: String = mask(forCountry: countryCode)
      
        guard let phoneNumberParsed = try? codeLength > 0
                ? phoneNumberKit.parse(
                    String(phoneNumber.dropFirst(codeLength)),
                    withRegion: countryCode ?? defaultRegionCode,
                    ignoreType: true)
                : phoneNumberKit.parse(phoneNumber, ignoreType: true)
        else {
            
            return phoneNumber.applyPatternOnPhoneNumber(mask: mask)
        }
       
           if phoneNumberKit.getRegionCode(of: phoneNumberParsed) != "RU" {
              
               return phoneNumber.applyPatternOnPhoneNumber(mask: mask)
           }
        
        return phoneNumberKit.format(phoneNumberParsed, toType: .international)
    }
    
    private func addCodeRuIfNeeded(_ input: String) -> String {
        return input.hasPrefix("89") ? "79" + input.dropFirst(2) : input
    }
    
    func countryCodeLength(by code: String?) -> Int {
        guard let code else { return 0 }
        return phoneNumberKit.countryCode(for: code)?.countDigits ?? 0
    }
    
    private func mask(forCountry countryCode: String?) -> String {
        countryCode.map {
            phoneNumberKit.getFormattedExampleNumber(forCountry: $0)?.getMaskedNumber() ?? .defaultMask
        }
        ?? .defaultMask
    }
}

private extension String {
    static let defaultMask: Self = "+X XXX XXX-XX-XX"
}

extension UInt64 {
    var countDigits: Int {
        return String(describing: self).count
    }
}
