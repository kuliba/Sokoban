//
//  NumberFormatter+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

extension NumberFormatter {
    
    static var fee: NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    
    static func currency(with currencySymbol: String) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }
    
    static var distance: LengthFormatter {
        
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }

    static var currencyRate: NumberFormatter {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")

        return formatter
    }

    static var persent: NumberFormatter {

        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")

        return formatter
    }
}
