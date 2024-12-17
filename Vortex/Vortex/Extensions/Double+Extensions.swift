//
//  Double+Extensions.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 23.08.2022.
//

import Foundation

extension Double {
    
    static func equal(_ lhs: Double, _ rhs: Double, decimalPrecision value: Int) -> Bool {
       return lhs.precised(value) == rhs.precised(value)
     }

     func precised(_ value: Int = 1) -> Double {
       let offset = pow(10, Double(value))
       return (self * offset).rounded() / offset
     }
    
    func roundUp(decimalPrecision precision: Int = 2) -> Double {
        
        let nearest = 1 / pow(10.0, Double(precision))
        let div = (self / nearest).precised(12)
        return (ceil(div) * nearest).precised(precision)
    }
    
    func roundDown(decimalPrecision precision: Int = 2) -> Double {
        let multiplier = pow(10, Double(precision))
        return trunc(self * multiplier) / multiplier
    }
    
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
