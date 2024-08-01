//
//  DepositCalculateAmountViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import Foundation
import SwiftUI

class DepositCalculateAmountViewModel: ObservableObject {

    @Published var value: Double
    @Published var isFirstResponder: Bool
    @Published var depositValue: String
    @Published var interestRateValue: Double
    @Published var isShowBottomSheet: Bool

    let depositTerm: String
    let interestRate: String
    let depositAmount: String
    let bounds: ClosedRange<Double>
    let minSum: String

    init(depositTerm: String = "Срок вклада",
         interestRate: String = "Процентная ставка",
         interestRateValue: Double,
         depositAmount: String = "Сумма депозита",
         value: Double = 1500000,
         isFirstResponder: Bool = false,
         depositValue: String,
         minSum: Double,
         isShowBottomSheet: Bool = false,
         bounds: ClosedRange<Double> = 10000...5000000) {

        self.depositTerm = depositTerm
        self.interestRate = interestRate
        self.interestRateValue = interestRateValue
        self.depositAmount = depositAmount
        self.value = value
        self.isFirstResponder = isFirstResponder
        self.depositValue = depositValue
        self.isShowBottomSheet = isShowBottomSheet
        self.bounds = bounds
        self.minSum = "От \(minSum.currencyFormatter())"
    }
}

extension DepositCalculateAmountViewModel {

    var valueCurrency: String {
        value.currencyDepositFormatter()
    }

    var valueCurrencySymbol: String {
        "\(value.currencyDepositFormatter(symbol: "₽"))"
    }

    var interestRateValueCurrency: String {
        interestRateValue.currencyDepositFormatter(symbol: "%")
    }

    var lowerBoundCurrency: String {
        "От \(bounds.lowerBound.currencyDepositShortFormatter())"
    }
    
    var lowerBound: Double {
        bounds.lowerBound
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        DispatchQueue.main.async {

            let filtered = textField.text?.filtered()

            guard let text = filtered, let value = Double(text) else {
                textField.text = self.valueCurrency
                return
            }
            
            if value < self.lowerBound {
                self.value = self.lowerBound
            } else {
                self.value = min(value, self.bounds.upperBound)
            }

            self.isFirstResponder = false
        }
    }
}

extension DepositCalculateAmountViewModel {

    static let sample1 = DepositCalculateAmountViewModel(
        interestRateValue: 7.95,
        depositValue: "365", minSum: 5000.0
    )

    static let sample2 = DepositCalculateAmountViewModel(
        interestRateValue: 9.15,
        depositValue: "31",
        minSum: 5000.0, bounds: 5000...10000000
    )
}
