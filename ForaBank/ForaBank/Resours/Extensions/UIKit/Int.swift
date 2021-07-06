//
//  Int.swift
//  ForaBank
//
//  Created by Mikhail on 17.06.2021.
//

import UIKit

extension Double {
    func currencyFormatter(symbol: String = "₽") -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.currencySymbol = symbol

        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }
        return String(self)
        
    }
}
