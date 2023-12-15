//
//  DecimalFormatter.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import Foundation

// model.dictionaryCurrencySymbol(for code: String) -> String?
// model.dictionaryCurrencySymbol(productData.currency)
public struct DecimalFormatter {
    
    private let formatter: NumberFormatter
    
    public init(
        currencySymbol: String,
        locale: Locale = .current
    ) {
        self.formatter = .currency(
            with: currencySymbol,
            locale: locale
        )
    }
    
    public func format(_ decimal: Decimal) -> String? {
        
        formatter.string(from: NSDecimalNumber(decimal: decimal))
    }
    
    public func number(from string: String?) -> Decimal {
        
        guard let string = string,
              let number = formatter.number(from: string)
        else { return .zero }
        
        return number.decimalValue
    }
    
    /// Remove all characters from a string except digits and the decimal separator.
    public func filter(
        text: String,
        allowDecimalSeparator: Bool
    ) -> String {
        
        let decimalSeparator = formatter.decimalSeparator
        
        var allowedCharacterSet = CharacterSet.decimalDigits
        
        if allowDecimalSeparator, let decimalSeparator {
            
            allowedCharacterSet.insert(charactersIn: decimalSeparator)
        }
        
        return .init(text.filter {
            
            guard let first = $0.unicodeScalars.first
            else { return false }
            
            return allowedCharacterSet.contains(first)
        })
    }
    
    /// Returns `true` if `text` has `decimalSeparator`.
    public func hasDecimalSeparator(
        _ text: String
    ) -> Bool {
        
        text.contains(formatter.decimalSeparator)
    }
    
    /// Returns `true` if `text` is `decimalSeparator`.
    public func isDecimalSeparator(
        _ text: String
    ) -> Bool {
        
        text == formatter.decimalSeparator
    }
}

private extension NumberFormatter {
    
    // NumberFormatter+Extensions.swift:21
    static func currency(
        with currencySymbol: String,
        locale: Locale = .current
    ) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = locale
        return formatter
    }
}
