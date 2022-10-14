//
//  DepositCalculatorViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 03.05.2022.
//

import Foundation
import SwiftUI
import Combine

class DepositCalculatorViewModel {

    let title = "Рассчитать доход"
    
    let depositModels: DepositInterestRateModel
    let capitalization: DepositCapitalizationViewModel?
    let calculateAmount: DepositCalculateAmountViewModel
    let totalAmount: DepositTotalAmountViewModel
    let bottomSheet: DepositBottomSheetViewModel

    private var bindings = Set<AnyCancellable>()
    
    init(depositModels: DepositInterestRateModel, capitalization: DepositCapitalizationViewModel?, calculateAmount: DepositCalculateAmountViewModel, totalAmount: DepositTotalAmountViewModel, bottomSheet: DepositBottomSheetViewModel) {
        self.depositModels = depositModels
        self.capitalization = capitalization
        self.calculateAmount = calculateAmount
        self.totalAmount = totalAmount
        self.bottomSheet = bottomSheet
    }
    
    convenience init(with deposit: DepositProductData) {
        
        if deposit.termRateCapList != nil {
            
            self.init(depositModels: .init(points: Self.reduceModels(with: deposit)), capitalization: .sample, calculateAmount: .init(interestRateValue: deposit.termRateList[0].termRateSum[0].termRateList[0].rate, depositValue: "", minSum: deposit.generalСondition.minSum, bounds: deposit.generalСondition.minSum...deposit.generalСondition.maxSum),totalAmount: .init(), bottomSheet: .init(items: .init(Self.reduceBottomSheetItem(with: deposit))))
            
        } else {
            
            self.init(depositModels: .init(points: Self.reduceModels(with: deposit)), capitalization: nil, calculateAmount: .init(interestRateValue: deposit.termRateList[0].termRateSum[0].termRateList[0].rate, depositValue: "", minSum: deposit.generalСondition.minSum, bounds: deposit.generalСondition.minSum...deposit.generalСondition.maxSum), totalAmount: .init(), bottomSheet: .init(items: .init(Self.reduceBottomSheetItem(with: deposit))))

        }
        
        if let firstPoint = depositModels.points[0].termRateLists.first {
            self.bottomSheet.selectedItem = firstPoint
        }
        
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

                let termList = isOn ? point.termRateCapLists : point.termRateLists

                calculateAmount(value: calculateAmount.value, termList: termList)

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
//                        bottomSheet.items =
                    } else {
//                        bottomSheet.items = point.termRateLists
                    }
                }

                bottomSheet.items.forEach { item in
                    if let capitalization = capitalization {
                        item.isOnCapitalization = capitalization.isOn
                    }
                }

                bottomSheet.items.forEach { item in
                    if let capitalization = capitalization {
                        item.isOnCapitalization = capitalization.isOn
                    }
                }

                bottomSheet.isShowBottomSheet = isShow

            }.store(in: &bindings)

        calculateAmount.$value
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in

                let point = depositModels.points
                    .last { point in
                        point.minSumm <= value
                    }

                guard let point = point else {
                    return
                }

                let isOnCapitalization = capitalization?.isOn ?? false
                let termList = isOnCapitalization ? point.termRateCapLists : point.termRateLists
                
                calculateAmount(value: value, termList: termList)

            }.store(in: &bindings)

        bottomSheet.$selectedItem
             .receive(on: DispatchQueue.main)
             .sink { [unowned self] selectedItem in

                 let point = depositModels.points
                     .last { point in
                         point.minSumm <= calculateAmount.value
                     }

                 guard let point = point else {
                     return
                 }
                 
                 calculateAmount.depositValue = selectedItem.termName

                 let isOnCapitalization = capitalization?.isOn ?? false
                 let termList = isOnCapitalization ? point.termRateCapLists : point.termRateLists
                 
                 let itemViewModel = termList.first { model in
                     model.termName == calculateAmount.depositValue
                 }

                 guard let itemViewModel = itemViewModel else {
                     return
                 }
                 
                 calculateAmount.interestRateValue = itemViewModel.rate

                 let yourIncome = calculateYourIncome(initialAmount: calculateAmount.value,
                                                      interestRate: selectedItem.rate,
                                                      termDay: selectedItem.term)
                 totalAmount.yourIncome = yourIncome

                 let totalAmount = calculateAmount.value + yourIncome
                 self.totalAmount.totalAmount = totalAmount

             }.store(in: &bindings)
    }
}

//MARK: - reducers

extension DepositCalculatorViewModel {
    
    static func reduceModels(with deposit: DepositProductData) -> [DepositCalculatorViewModel.DepositInterestRatePoint] {
        
        var points: [DepositCalculatorViewModel.DepositInterestRatePoint] = []
        
        var point: [DepositBottomSheetItemViewModel] = []
        var capPoint: [DepositBottomSheetItemViewModel] = []
        var sum: Double = 0.0
        
        for termRateList in deposit.termRateList[0].termRateSum {
            
            sum = termRateList.sum
            point = []
            capPoint = []
            
            for i in termRateList.termRateList {
                
                point.append(.init(term: i.term, rate: i.rate, termName: i.termName))
                
                if let capList = deposit.termRateCapList {
                    
                    for capList in capList[0].termRateSum.filter({$0.sum == sum}) {
                        
                        for cap in capList.termRateList {
                            
                            capPoint.append(.init(term: cap.term, rate: cap.rate, termName: cap.termName))
                        }
                        
                        points.append(.init(minSumm: sum, termRateLists: point, termRateCapLists: capPoint))
                        
                    }
                    
                } else {
                    
                    points.append(.init(minSumm: sum, termRateLists: point, termRateCapLists: capPoint))
                }
            }
        }
        
        return points
    }
    
    static func reduceBottomSheetItem(with deposit: DepositProductData) -> [DepositBottomSheetItemViewModel] {
        
        var items: [DepositBottomSheetItemViewModel] = []
        
        if let termCapList = deposit.termRateCapList {
            
            for item in termCapList {
                
                if let term = item.termRateSum.last?.termRateList {
                    
                    for i in term {
                        
                        items.append(.init(term: i.term, rate: i.rate, termName: i.termName))
                    }
                }
            }
            
        } else {
            
            for item in deposit.termRateList {
                
                if let term = item.termRateSum.last?.termRateList {
                    
                    for i in term {
                        
                        items.append(.init(term: i.term, rate: i.rate, termName: i.termName, isOnCapitalization: false))
                    }
                }
            }
        }
        
        return items
    }
}

extension DepositCalculatorViewModel {

    private func calculateYourIncome(initialAmount: Double, interestRate: Double, termDay: Int) -> Double {
        (initialAmount * interestRate * Double(termDay) / 365) / 100
    }

    func calculateAmount(value: Double, termList: [DepositBottomSheetItemViewModel]) {

        let itemViewModel = termList.first { model in
            model.termName == calculateAmount.depositValue
        }

        guard let itemViewModel = itemViewModel else {
            return
        }

        let yourIncome = calculateYourIncome(initialAmount: value,
                                             interestRate: itemViewModel.rate,
                                             termDay: itemViewModel.term)

        self.calculateAmount.interestRateValue = itemViewModel.rate
        self.totalAmount.yourIncome = yourIncome

        let totalAmount = value + yourIncome
        self.totalAmount.totalAmount = totalAmount
    }
}

extension DepositCalculatorViewModel {

    struct DepositInterestRateModel {

        let points: [DepositInterestRatePoint]
    }

    struct DepositInterestRatePoint {

        let minSumm: Double

        var termRateLists: [DepositBottomSheetItemViewModel]
        var termRateCapLists: [DepositBottomSheetItemViewModel]
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
        capitalization: .init(title: "С учетом капитализации"),
        calculateAmount: .sample1,
        totalAmount: .init(),
        bottomSheet: .init(
            title: "Срок вклада",
            items: [
                .init(term: 365, rate: 8.25, termName: "1 год"),
                .init(term: 540, rate: 13.06, termName: "1 год 6 месяцев")
            ],
            selectedItem: .init(term: 365, rate: 8.25, termName: "1 год")
        )
    )

    static let sample2 = DepositCalculatorViewModel(
        depositModels: .points2,
        capitalization: nil,
        calculateAmount: .sample2,
        totalAmount: .init(),
        bottomSheet: .init(
            title: "Срок вклада",
            items: [
                .init(term: 31, rate: 9.15, termName: "1 месяц"),
                .init(term: 92, rate: 10, termName: "3 месяца")
            ],
            selectedItem: .init(term: 31, rate: 9.15, termName: "1 месяц")
        )
    )
}
