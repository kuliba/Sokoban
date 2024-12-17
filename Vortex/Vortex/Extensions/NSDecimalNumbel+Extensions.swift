//
//  NSDecimalNumbel+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2023.
//

import Foundation

extension NSDecimalNumber {
    
    func rounded(scale: Int16) -> NSDecimalNumber {
        
        let behavior = NSDecimalNumberHandler(roundingMode: .plain, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

       return self.rounding(accordingToBehavior: behavior)
    }
    
    func roundedFinance() -> NSDecimalNumber {
        
        rounded(scale: 2)
    }
}
