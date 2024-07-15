//
//  Model+Formatters.swift
//  ForaBank
//
//  Created by Max Gribov on 31.05.2022.
//

import Foundation

extension Model {
    
    enum AmountFormatStyle {
        
        case normal
        case fraction
        case clipped
    }
    
    func amountFormatted(amount: Double, productID: ProductData.ID, style: AmountFormatStyle) -> String? {
        
        let product = product(productId: productID)
        
        return amountFormatted(amount: amount, currencyCode: product?.currency, style: style)
    }
    
    func amountFormatted(amount: Double, currencyCode: String?, style: AmountFormatStyle) -> String? {
        
        guard let currencyCode = currencyCode,
              let currencyData = dictionaryCurrency(for: currencyCode) else {
            return nil
        }
        
        return amountFormatted(amount: amount, currencyData: currencyData, style: style)
    }
    
    func amountFormatted(amount: Double, currencyCode: String, style: AmountFormatStyle) -> String? {
        
        guard let currencyData = dictionaryCurrency(for: currencyCode) else {
            return nil
        }
        
        return amountFormatted(amount: amount, currencyData: currencyData, style: style)
    }
    
    func normalAmountFormatted(amount: Double, currencyCode: String) -> String? {
        
        return amountFormatted(amount: amount, currencyCode: currencyCode, style: .normal)
    }
    
    func amountFormatted(amount: Double, currencyCodeNumeric: Int, style: AmountFormatStyle) -> String? {
        
        guard let currencyData = dictionaryCurrency(for: currencyCodeNumeric) else {
            return nil
        }
        
        return amountFormatted(amount: amount, currencyData: currencyData, style: style)
    }
    
    func amountFormatted(amount: Double, currencyData: CurrencyData, style: AmountFormatStyle) -> String? {
        
        guard let currencySymbol = currencyData.currencySymbol else {
            return nil
        }
        
        let formatter: NumberFormatter = .currency(with: currencySymbol)
        
        switch style {
        case .normal:
            
            return formatter.string(from: NSNumber(value: amount))
            
        case .fraction:
            
            let formatter: NumberFormatter = .currency(currencySymbol)
            return formatter.string(from: NSNumber(value: amount))
            
        case .clipped:
            
            let lowerBound: Double = 1_000_000
            let upperBound: Double = 1_000_000_000
            
            if amount < lowerBound {
                
                return formatter.string(from: NSNumber(value: amount))
                
            } else if lowerBound...upperBound ~= amount {
                
                formatter.currencySymbol = "Млн. \(currencySymbol)"
                formatter.maximumFractionDigits = 2
                
                return formatter.string(from: NSNumber(value: amount / lowerBound))
                
            } else {
                
                formatter.currencySymbol = "Млрд. \(currencySymbol)"
                formatter.maximumFractionDigits = 2
                
                return formatter.string(from: NSNumber(value: amount / upperBound))
            }
        }
    }
    
    func formatted(_ amount: Decimal, with currencyCode: String) -> String? {
        
        guard let currencyData = dictionaryCurrency(for: currencyCode),
              let currencySymbol = currencyData.currencySymbol
        else { return nil }
        
        let formatter: NumberFormatter = .currency(with: currencySymbol)
        let amount = NSDecimalNumber(decimal: amount)
        
        return formatter.string(from: amount)
    }
}
