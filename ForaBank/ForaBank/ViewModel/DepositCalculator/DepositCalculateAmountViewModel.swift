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
    @Published var depositValue: Int
    @Published var interestRateValue: Double
    @Published var isShowBottomSheet: Bool

    let depositTerm: String
    let interestRate: String
    let depositAmount: String
    let bounds: ClosedRange<Double>

    init(depositTerm: String = "Срок вклада",
         interestRate: String = "Процентная ставка",
         interestRateValue: Double,
         depositAmount: String = "Сумма депозита",
         value: Double = 1500000,
         isFirstResponder: Bool = false,
         depositValue: Int,
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
        interestRateValue.currencyDepositFormatter(symbol: "₽")
    }

    var lowerBoundCurrency: String {
        "От \(bounds.lowerBound.currencyDepositShortFormatter())"
    }
}

extension DepositCalculateAmountViewModel {

    static let sample1 = DepositCalculateAmountViewModel(
        interestRateValue: 7.95,
        depositValue: 365
    )

    static let sample2 = DepositCalculateAmountViewModel(
        interestRateValue: 9.15,
        depositValue: 31,
        bounds: 5000...10000000
    )
}
