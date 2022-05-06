//
//  DepositCalculatorViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 03.05.2022.
//

import Foundation
import SwiftUI
import Combine

class DepositCalculatorViewModel: ObservableObject {

    let title = "Рассчитать доход"
    
    let depositModels: DepositInterestRateModel
    let capitalization: DepositCapitalizationViewModel?
    let calculateAmount: DepositCalculateAmountViewModel
    let totalAmount: DepositTotalAmountViewModel
    let bottomSheet: DepositBottomSheetViewModel

    private var bindings = Set<AnyCancellable>()

    init(depositModels: DepositInterestRateModel,
         capitalization: DepositCapitalizationViewModel?,
         calculateAmount: DepositCalculateAmountViewModel,
         totalAmount: DepositTotalAmountViewModel,
         bottomSheet: DepositBottomSheetViewModel) {

        self.depositModels = depositModels
        self.capitalization = capitalization
        self.calculateAmount = calculateAmount
        self.totalAmount = totalAmount
        self.bottomSheet = bottomSheet

        bind()
    }

    private func bind() {

        capitalization?.$isOn
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isOn in

                let point = depositModels.points
                    .compactMap {$0}
                    .last { point in
                        point.minSumm <= calculateAmount.value
                    }

                guard let point = point else {
                    return
                }

                let list = isOn ? point.termRateCapLists : point.termRateLists

                let model = list.first { model in
                    model.term == Int(calculateAmount.depositValue)
                }

                guard let model = model else {
                    return
                }

                calculateAmount.interestRateValue = model.rate

                let yourIncome = (calculateAmount.value * model.rate * Double(model.term) / 365) / 100
                totalAmount.yourIncome = yourIncome

                let totalAmount = calculateAmount.value + yourIncome
                self.totalAmount.totalAmount = totalAmount

            }.store(in: &bindings)

        calculateAmount.$isShowBottomSheet
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isShow in

                let point = depositModels.points
                    .compactMap {$0}
                    .last { point in
                        point.minSumm <= calculateAmount.value
                }

                guard let point = point else {
                    return
                }

                if isShow {

                    if let capitalization = capitalization {
                        bottomSheet.items = capitalization.isOn ? point.termRateCapLists : point.termRateLists
                    } else {
                        bottomSheet.items = point.termRateLists
                    }
                }

                bottomSheet.isShowBottomSheet = isShow

            }.store(in: &bindings)

        calculateAmount.$value
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in

                let point = depositModels.points
                    .compactMap {$0}
                    .last { point in
                        point.minSumm <= value
                    }

                guard let point = point else {
                    return
                }

                let isOnCapitalization = capitalization?.isOn ?? false
                let list = isOnCapitalization ? point.termRateCapLists : point.termRateLists

                let model = list.first { model in
                    model.term == calculateAmount.depositValue
                }

                guard let model = model else {
                    return
                }

                calculateAmount.interestRateValue = model.rate

                let yourIncome = (value * model.rate * Double(model.term) / 365) / 100
                totalAmount.yourIncome = yourIncome

                let totalAmount = value + yourIncome
                self.totalAmount.totalAmount = totalAmount

            }.store(in: &bindings)

        bottomSheet.$viewModel
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] model in

                calculateAmount.depositValue = model.term
                calculateAmount.interestRateValue = model.rate

                let yourIncome = (calculateAmount.value * model.rate * Double(model.term) / 365) / 100
                totalAmount.yourIncome = yourIncome

                let totalAmount = calculateAmount.value + yourIncome
                self.totalAmount.totalAmount = totalAmount

            }.store(in: &bindings)
    }
}

extension DepositCalculatorViewModel {

    struct DepositInterestRateModel {

        let points: [DepositInterestRatePoint]
    }

    struct DepositInterestRatePoint {

        let minSumm: Double

        let termRateLists: [DepositBottomSheetItemViewModel]
        let termRateCapLists: [DepositBottomSheetItemViewModel]
    }
}

extension DepositCalculatorViewModel.DepositInterestRateModel {

    static let points1 = DepositCalculatorViewModel.DepositInterestRateModel(
        points: [
            .init(minSumm: 10000,
                  termRateLists: [
                    .init(term: 365, rate: 7.95, termName: "1 год"),
                    .init(term: 540, rate: 12, termName: "1 год 6 месяцев"),
                  ],
                  termRateCapLists: [
                    .init(term: 365, rate: 8.25, termName: "1 год"),
                    .init(term: 540, rate: 13.06, termName: "1 год 6 месяцев")
                  ]),
            .init(minSumm: 1500000,
                  termRateLists: [
                    .init(term: 365, rate: 8.15, termName: "1 год"),
                    .init(term: 540, rate: 12.5, termName: "1 год 6 месяцев"),
                  ],
                  termRateCapLists: [
                    .init(term: 365, rate: 8.46, termName: "1 год"),
                    .init(term: 540, rate: 13.65, termName: "1 год 6 месяцев")
                  ]),
            .init(minSumm: 3000000,
                  termRateLists: [
                    .init(term: 365, rate: 8.35, termName: "1 год"),
                    .init(term: 540, rate: 13, termName: "1 год 6 месяцев"),
                  ],
                  termRateCapLists: [
                    .init(term: 365, rate: 8.68, termName: "1 год"),
                    .init(term: 540, rate: 14.25, termName: "1 год 6 месяцев")
                  ])
        ])

    static let points2 = DepositCalculatorViewModel.DepositInterestRateModel(
        points: [
            .init(minSumm: 5000,
                  termRateLists: [
                    .init(term: 31, rate: 9.15, termName: "1 месяц"),
                    .init(term: 92, rate: 10, termName: "3 месяца")
                  ],
                  termRateCapLists: [])
        ])
}

extension DepositCalculatorViewModel {

    static let sample1 = DepositCalculatorViewModel(
        depositModels: .points1,
        capitalization: .init(
            title: "С учетом капитализации",
            named: "Calculate Capitalization"),
        calculateAmount: .sample1,
        totalAmount: .init(
            yourIncome: 102099.28,
            totalAmount: 1565321.08),
        bottomSheet: .init(
            title: "Срок вклада",
            items: [
                .init(term: 365, rate: 8.25, termName: "1 год"),
                .init(term: 540, rate: 13.06, termName: "1 год 6 месяцев")
            ],
            viewModel: .init(term: 365, rate: 8.25, termName: "1 год")
        )
    )

    static let sample2 = DepositCalculatorViewModel(
        depositModels: .points2,
        capitalization: nil,
        calculateAmount: .sample2,
        totalAmount: .init(
            yourIncome: 102099.28,
            totalAmount: 1565321.08),
        bottomSheet: .init(
            title: "Срок вклада",
            items: [
                .init(term: 31, rate: 9.15, termName: "1 месяц"),
                .init(term: 92, rate: 10, termName: "3 месяца")
            ],
            viewModel: .init(term: 31, rate: 9.15, termName: "1 месяц")
        )
    )
}
