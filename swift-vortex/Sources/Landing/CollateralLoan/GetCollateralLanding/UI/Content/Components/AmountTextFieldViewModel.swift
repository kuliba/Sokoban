//
//  AmountTextFieldViewModel.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 11.03.2025.
//

//import Combine
//import UIKit
//
//public class AmountTextFieldViewModel {
//
//    var value: Double
//    var isFirstResponder: Bool
//    var bounds: ClosedRange<Double>
//
//    public init(
//        value: Double = 3_000_000,
//        isFirstResponder: Bool = false,
//        bounds: ClosedRange<Double> = 1_000_000...15_000_000
//    ) {
//        self.value = value
//        self.isFirstResponder = isFirstResponder
//        self.bounds = bounds
//    }
//}
//
//extension AmountTextFieldViewModel {
//
//    var valueCurrency: String {
//        
//        value.currencyDepositFormatter()
//    }
//
//    var valueCurrencySymbol: String {
//        "\(value.currencyDepositFormatter(symbol: "₽"))"
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        DispatchQueue.main.async {
//
//            let filtered = textField.text?.filter { $0.isNumber }
//
//            guard let text = filtered, let value = Double(text) else {
//
//                textField.text = self.valueCurrency
//                return
//            }
//            
//            if value < self.lowerBound {
//
//                self.value = self.lowerBound
//            } else {
//
//                self.value = min(value, self.bounds.upperBound)
//            }
//
////            self.isFirstResponder = false
//        }
//    }
//    
//    var lowerBound: Double {
//        bounds.lowerBound
//    }
//}
//
//extension Double {
//    
//    func currencyDepositFormatter(symbol: String = "") -> String { // TODO: Инжектировать
//
//        let currencyFormatter = NumberFormatter()
//        currencyFormatter.usesGroupingSeparator = true
//        currencyFormatter.numberStyle = .currency
//        currencyFormatter.locale = Locale(identifier: "ru_RU")
//        currencyFormatter.currencySymbol = symbol
//
//        if String(self).components(separatedBy: ".").last == "0" {
//            currencyFormatter.maximumFractionDigits = 0
//        }
//
//        if let priceString = currencyFormatter.string(from: NSNumber(value: self)) {
//            return priceString
//        }
//
//        return String(self)
//    }
//}
