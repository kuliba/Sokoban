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
    
    public init(currencySymbol: String) {
        
        self.formatter = .currency(with: currencySymbol)
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
}

private extension NumberFormatter {
    
    // NumberFormatter+Extensions.swift:21
    static func currency(
        with currencySymbol: String
    ) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        return formatter
    }
}
