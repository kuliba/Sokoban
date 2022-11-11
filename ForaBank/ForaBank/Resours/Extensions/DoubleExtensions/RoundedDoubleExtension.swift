//
//  RoundedDoubleExtension.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func currencyFormatter() -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.currencySymbol = "₽"
        
        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }
        return String(self)
        
    }

    func currencyDepositFormatter(symbol: String = "") -> String {

        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.currencySymbol = symbol

        if String(self).components(separatedBy: ".").last == "0" {
            currencyFormatter.maximumFractionDigits = 0
        }

        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }

        return String(self)
    }

    func currencyDepositShortFormatter() -> String {

        let currencyFormatter = NumberFormatter()

        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.currencySymbol = "тыс. ₽"
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.minimumFractionDigits = 0

        if let priceString = currencyFormatter.string(from: NSNumber(value: self / 1000)) {
            return priceString
        }
        return String(self)
    }

    func percentDepositFormatter() -> String {

        let currencyFormatter = NumberFormatter()

        currencyFormatter.numberStyle = .percent
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2

        if let priceString = currencyFormatter.string(from: NSNumber(value: self / 100)) {
            return priceString
        }

        return String(self)
    }
    
    func currencyFormatterForMain() -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        
        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }
        return String(self)
        
    }
    
    @available(*, deprecated, message: "Use Model func amountFormatted(amount: Double, currencyCode: String?, style: AmountFormatStyle) -> String? in Model+Formatter.swift file")
    func currencyFormatter(symbol: String = "") -> String {
        
        var resultString = ""
        let currArr = Model.shared.currencyList.value.map { $0.getCurrencyList() }
        currArr.forEach({ currency in
            if currency.code == symbol {
                var symbolArr = currency.cssCode?.components(separatedBy: "\\")
                symbolArr?.removeFirst()
                symbolArr?.forEach { qqqq in
                    if let charCode = UInt32(qqqq, radix: 16), let unicode = UnicodeScalar(charCode) {
                        let str = String(unicode)
                        resultString.append(str)
                    }
                    else {

                    }
                }
            }
        })
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        
        if self < 1_000_000 {
            currencyFormatter.currencySymbol = resultString
            let maximumDigits = UserDefaults.standard.object(forKey: "maximumFractionDigits") as? Int
            
            if String(self).components(separatedBy: ".").last == "0" {
                currencyFormatter.maximumFractionDigits = 0
            } else {
                currencyFormatter.maximumFractionDigits = maximumDigits ?? 2
            }
            
            if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
                return priceString
            }
            return String(self)
        } else if (self >= 1_000_000 && self < 1_000_000_000) {
            currencyFormatter.currencySymbol = "Млн. " + resultString
            let tempDoubleSelf = self / 1_000_000
            if let priceString = currencyFormatter.string(from: NSNumber(value: tempDoubleSelf)) {
                return priceString
            }
        } else if self >= 1_000_000_000 {
            currencyFormatter.currencySymbol = "Млрд. " + resultString
            let tempDoubleSelf = self / 1_000_000_000
            if let priceString = currencyFormatter.string(from: NSNumber(value: tempDoubleSelf)) {
                return priceString
            }
        }
        return String(self)
    }
    
    func fullCurrencyFormatter(symbol: String = "") -> String {
        
        var resultString = ""
        let currArr = Dict.shared.currencyList
        currArr?.forEach({ currency in
            if currency.code == symbol {
                var symbolArr = currency.cssCode?.components(separatedBy: "\\")
                symbolArr?.removeFirst()
                symbolArr?.forEach { qqqq in
                    if let charCode = UInt32(qqqq, radix: 16), let unicode = UnicodeScalar(charCode) {
                        let str = String(unicode)
                        resultString.append(str)
                    }
                    else {

                    }
                }
            }
        })
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.currencySymbol = resultString
        let maximumDigits = UserDefaults.standard.object(forKey: "maximumFractionDigits") as? Int
        
        if String(self).components(separatedBy: ".").last == "0" {
            currencyFormatter.maximumFractionDigits = 0
        } else {
            currencyFormatter.maximumFractionDigits = maximumDigits ?? 2
        }
        
        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }
        return String(self)
    }
}
