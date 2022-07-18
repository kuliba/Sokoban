//
//  Double+Extensions.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 18.07.2022.
//

import Foundation

extension Double {
    
    func decimal() -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        
        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }
        return String(self)
    }
}
