//
//  DepositTotalAmountViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import SwiftUI

class DepositTotalAmountViewModel: ObservableObject {

    @Published var yourIncome: Double
    @Published var totalAmount: Double

    let yourIncomeTitle: String
    let totalAmountTitle: String
    let description: String

    init(yourIncome: Double = 0,
         totalAmount: Double = 0,
         yourIncomeTitle: String = "Ваш доход",
         totalAmountTitle: String = "Итоговая сумма",
         description: String = "Представленные параметры являются расчетными и носят справочный характер") {

        self.yourIncomeTitle = yourIncomeTitle
        self.totalAmountTitle = totalAmountTitle
        self.yourIncome = yourIncome
        self.totalAmount = totalAmount
        self.description = description
    }
}

extension DepositTotalAmountViewModel {

    static let sample = DepositTotalAmountViewModel(
        yourIncome: 102099.28,
        totalAmount: 1565321.08
    )
}
