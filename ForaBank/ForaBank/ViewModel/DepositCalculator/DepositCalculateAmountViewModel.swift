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
         depositValue: Int,
         isShowBottomSheet: Bool = false,
         bounds: ClosedRange<Double>) {

        self.depositTerm = depositTerm
        self.interestRate = interestRate
        self.interestRateValue = interestRateValue
        self.depositAmount = depositAmount
        self.value = value
        self.depositValue = depositValue
        self.isShowBottomSheet = isShowBottomSheet
        self.bounds = bounds
    }
}

extension DepositCalculateAmountViewModel {

    var numberFormatter: NumberFormatter {

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ru_RU")

        return formatter
    }

    func percentFormat(_ value: Double) -> String {

        let formatter = NumberFormatter()
        let number = NSNumber(value: value / 100)

        formatter.numberStyle = .percent

        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: number) ?? ""
    }
}

extension DepositCalculateAmountViewModel {

    static let sample1 = DepositCalculateAmountViewModel(
        interestRateValue: 7.95,
        depositValue: 365, bounds: 10000...500000
    )

    static let sample2 = DepositCalculateAmountViewModel(
        interestRateValue: 9.15,
        depositValue: 31,
        bounds: 5000...10000000
    )
}
