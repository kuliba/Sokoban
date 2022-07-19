//
//  CurrencyBigListViewComponentMock.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 16.07.2022.
//

import SwiftUI

extension CurrencyBigListView.ViewModel {

    static var sample: CurrencyBigListView.ViewModel =
        .init(
            titleList: "Курсы валют",
            content: .items(
               [.init(id: "USD",
                      mainImage: ("0", Image("Flag USD")),
                      nameCurrency: "Доллар",
                      buySection: .init(kindImage: .down, valueText: "68,19", type: .buy),
                      sellSection: .init(kindImage: .up, valueText: "69,45", type: .sell)),
               .init(id: "EUR",
                     mainImage: ("1", nil),
                     nameCurrency: "Евро",
                     buySection: .init(kindImage: .up, valueText: "69,23", type: .buy),
                     sellSection: .init(kindImage: nil, valueText: "70,01", type: .sell)),
               .init(id: "CHF",
                     mainImage: ("2", Image("Flag CHF")),
                     nameCurrency: "Франк",
                     buySection: .init(kindImage: .down, valueText: "64,89", type: .buy),
                     sellSection: .init(kindImage: .up, valueText: "65,09", type: .sell))]))

}
