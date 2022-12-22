//
//  CurrencyBigListViewComponentMock.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 16.07.2022.
//

import SwiftUI

extension CurrencyRatesListView.ViewModel {

    static var sample: CurrencyRatesListView.ViewModel =
        .init(
            titleList: "Курсы валют",
            content: .items(
               [.init(id: "USD",
                      mainImage: ("0", Image("Flag USD")),
                      codeTitle: "USD",
                      nameCurrency: "Доллар",
                      buySection: .init(kindImage: .down, valueText: "68,19", type: .buy),
                      sellSection: .init(kindImage: .up, valueText: "69,45", type: .sell)),
                .init(id: "AMD",
                       mainImage: ("1", nil),
                       codeTitle: "100 AMD",
                       nameCurrency: "Драм",
                       buySection: .init(kindImage: .down, valueText: "15,19", type: .buy),
                       sellSection: .init(kindImage: .up, valueText: "14,45", type: .sell)),
               .init(id: "EUR",
                     mainImage: ("2", nil),
                     codeTitle: "EUR",
                     nameCurrency: "Евро",
                     buySection: .init(kindImage: .up, valueText: "69,23", type: .buy),
                     sellSection: .init(kindImage: nil, valueText: "70,01", type: .sell)),
               .init(id: "CHF",
                     mainImage: ("3", Image("Flag CHF")),
                     codeTitle: "CHF",
                     nameCurrency: "Франк",
                     buySection: .init(kindImage: .down, valueText: "64,89", type: .buy),
                     sellSection: .init(kindImage: .up, valueText: "65,09", type: .sell))]))

}
