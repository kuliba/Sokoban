//
//  String+ext.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation

extension String {
    
    func formattedValue(_ currency: String) -> String {
        
        guard let value = Decimal(string: self) else { return " \(currency)" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return "\(formatter.string(for: value) ?? "") \(currency)"
    }
}
