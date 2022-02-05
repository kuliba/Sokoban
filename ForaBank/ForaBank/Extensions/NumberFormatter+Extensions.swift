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
    
    func currency(with currencyCode: String) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
}
