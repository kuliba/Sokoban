//
//  DecimalFormatter.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import Foundation

// model.dictionaryCurrencySymbol(for code: String) -> String?
// model.dictionaryCurrencySymbol(productData.currency)
struct DecimalFormatter {
    
    let format: (Decimal) -> String?
    let number: (String?) -> Decimal
    
    init(currencySymbol: String) {
        
        let formatter = NumberFormatter.currency(with: currencySymbol)
        
        self.format = {
            
            let double = NSDecimalNumber(decimal: $0).doubleValue
            return formatter.string(from: NSNumber(value: double))
        }
        
        self.number = { text in
            
            guard let text,
                  let value = formatter.number(from: text)
            else { return 0 }
            
            return value.decimalValue
        }
    }
}

private extension NumberFormatter {
    
    // NumberFormatter+Extensions.swift:21
    static func currency(with currencySymbol: String) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }
}
