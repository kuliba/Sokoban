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
    
    static func currency(with currencySymbol: String) -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }
    
    static func decimal() -> NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        return formatter
    }
    
    static func decimal(_ value: Double) -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.minimumFractionDigits = 2
        
        if let priceString = currencyFormatter.string(from: NSNumber(value: value)) {
            return priceString
        }
        
        return String(value)
    }
    
    static func decimal(_ value: String) -> Double? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        let number = formatter.number(from: value)
        
        guard let number = number?.doubleValue else {
            return nil
        }
        
        return number
    }

    //FIXME: refactor this
    static func decimal(totalBalance: String) -> String {

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.maximumFractionDigits = totalBalance
            .components(separatedBy: ".").last == "0" ? 0 : 2

        guard
            let value = Double(totalBalance),
            let balance = currencyFormatter.string(from: .init(value: value)) else {
            return totalBalance
        }

        return balance
    }

    //FIXME: refactor this
    static func currency(balance: String) -> String {

        let currencySymbol = "₽"
        let lowerBound: Double = 1_000_000
        let upperBound: Double = 1_000_000_000

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.maximumFractionDigits = balance
            .components(separatedBy: ".").last == "0" ? 0 : 2

        guard let value = Double(balance) else {
            return balance
        }

        if value < lowerBound {

            currencyFormatter.currencySymbol = currencySymbol

            if let balance = currencyFormatter.string(from: .init(value: value)) {
                return balance
            }
        } else if lowerBound...upperBound ~= value {

            currencyFormatter.currencySymbol = "Млн. \(currencySymbol)"

            if let balance = currencyFormatter.string(from: .init(value: value / lowerBound)) {
                return balance
            }
        } else if value >= upperBound {

            currencyFormatter.currencySymbol = "Млрд. \(currencySymbol)"

            if let balance = currencyFormatter.string(from: .init(value: value / upperBound)) {
                return balance
            }
        }

        return balance
    }
    
    static var distance: LengthFormatter {
        
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }
    
    static var currencyRate: NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }
    
    static var persent: NumberFormatter {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }
}
