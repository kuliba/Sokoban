//
//  Int.swift
//  ForaBank
//
//  Created by Mikhail on 17.06.2021.
//

import UIKit

extension Double {
    func currencyFormatter(code: String = "") -> String {
        
        
//        var symbolArr = code.components(separatedBy: "\\")
//        symbolArr.removeFirst()
//
//        var resultString = ""
//        symbolArr.forEach { qqqq in
//            if let charCode = UInt32(qqqq, radix: 16), let unicode = UnicodeScalar(charCode)
//            {
//                let str = String(unicode)
//                resultString.append(str)
//            }
//            else
//            {
//                print("invalid input")
//            }
//        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ru_RU")
        currencyFormatter.currencySymbol = code.getSymbol()

        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
            return priceString
        }
        return String(self)
        
    }
}
