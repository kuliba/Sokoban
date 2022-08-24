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
}
