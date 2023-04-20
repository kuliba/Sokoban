//
//  Decimal+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 20.04.2023.
//

import Foundation

extension Decimal {
    
    func roundedFinance() -> Decimal {
        
        NSDecimalNumber(decimal: self)
            .roundedFinance()
            .decimalValue
    }
}
