//
//  ConfigPreviews.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation

extension NumberFormatter {
    
    static func numberFormatterPreview() -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""

        return formatter
    }
}
