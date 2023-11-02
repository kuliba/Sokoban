//
//  PhoneNumberWrapper.swift
//
//
//  Created by Andryusina Nataly on 18.10.2023.
//

import PhoneNumberKit

public struct PhoneNumberWrapper {
    
    private let phoneNumberKit: PhoneNumberKit
    
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
        
        guard let phoneNumberParsed = try? phoneNumber.hasPrefix("79") ?
                phoneNumberKit.parse(
                    String(phoneNumber.dropFirst()),
                    withRegion: "RU",
                    ignoreType: true) :
                phoneNumberKit.parse(
                    phoneNumber,
                    ignoreType: true
                )
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
}

private extension Int {
    static let phoneNumberWithCodeLengthRU: Self = 11
    static let phoneNumberWithoutCodeLengthRU: Self = 10
}

private extension String {
    static let countryCodeRu: Self = "RU"
    static let nationalDigitalCodeRu: Self = "8"
}
