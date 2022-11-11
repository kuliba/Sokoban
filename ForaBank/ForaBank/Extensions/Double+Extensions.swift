//
//  Double+Extensions.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 23.08.2022.
//

import Foundation

extension Double {
    
    func round(roundingMode: NSDecimalNumber.RoundingMode = .plain, degree: Int = 2) -> Double {
        
        let divider = pow(10, Double(degree))
        let rounded = floor(self * divider) / divider
        
        let decimalNumber: NSDecimalNumber = .init(value: rounded)
        let decimalNumberHandler: NSDecimalNumberHandler = .init(roundingMode: roundingMode, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        
        decimalNumber.rounding(accordingToBehavior: decimalNumberHandler)
        
        return decimalNumber.doubleValue
    }
    
    func currencyFormatter(_ currencySymbol: String) -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = currencySymbol
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        
        if let value = currencyFormatter.string(from: NSNumber(value: self)) {
            return value
        }
        
        return String(self)
    }
}
