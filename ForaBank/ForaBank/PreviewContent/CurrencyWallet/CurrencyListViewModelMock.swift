//
//  CurrencyListViewModelMock.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 21.07.2022.
//

// MARK: - Preview Content

extension CurrencyListView.ViewModel {
    
    static let sample: CurrencyListView.ViewModel = .init(
        .emptyMock,
        currency: Currency(description: "USD"),
        items: [
            .init(icon: .init("Flag USD"),
                  currency: Currency(description: "USD"),
                  rateBuy: "68.19",
                  rateSell: "69.45",
                  rateBuyItem: 68.19,
                  rateSellItem: 69.45,
                  isSelected: true),
            .init(icon: .init("Flag EUR"),
                  currency: Currency(description: "EUR"),
                  rateBuy: "69.23",
                  rateSell: "70.01",
                  rateBuyItem: 69.23,
                  rateSellItem: 70.01),
            .init(icon: .init("Flag GBP"),
                  currency: Currency(description: "GBP"),
                  rateBuy: "75.65",
                  rateSell: "76.83",
                  rateBuyItem: 75.65,
                  rateSellItem: 76.83),
            .init(icon: .init("Flag CHF"),
                  currency: Currency(description: "CHF"),
                  rateBuy: "64.89",
                  rateSell: "65.09",
                  rateBuyItem: 64.89,
                  rateSellItem: 65.09),
            .init(icon: .init("Flag CHY"),
                  currency: Currency(description: "CHY"),
                  rateBuy: "18.45",
                  rateSell: "19.26",
                  rateBuyItem: 18.45,
                  rateSellItem: 19.26)
        ])
}
