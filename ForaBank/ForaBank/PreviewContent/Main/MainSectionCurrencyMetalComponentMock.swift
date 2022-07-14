//
//  MainSectionCurrencyMetalComponentMock.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 12.07.2022.
//
import SwiftUI

extension MainSectionCurrencyMetallView.ViewModel {
    
    convenience init() {
                
        self.init(content: .items([]), selector: nil, isCollapsed: false)
        self.content = .items(self.sampleItems)
    }
            
            
    var sampleItems: [MainSectionCurrencyMetallView.ViewModel.ItemViewModel] {
               
                [.init(type: .currency,
                       mainImg: ("0", Image("Flag USD")),
                       title: "USD",
                       subtitle: "Доллар",
                       action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                        .DidTapped.Item(code: Currency(description: "USD")))},
                       topDashboard: .init(kindImage: .down, valueText: "68,19", type: .buy, action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Buy(code: Currency(description: "USD")))}),
                       bottomDashboard: .init(kindImage: .up, valueText: "69,45", type: .sell, action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Sell(code: Currency(description: "USD")))} )),
                 .init(type: .currency,
                       mainImg: ("1", Image("Flag EUR")),
                       title: "EUR",
                       subtitle: "Евро",
                       action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Item(code: Currency(description: "EUR")))},
                       topDashboard: .init(kindImage: .up, valueText: "69,23", type: .buy, action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Buy(code: Currency(description: "EUR")))}),
                       bottomDashboard: .init(kindImage: .up, valueText: "70,01", type: .sell, action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Sell(code: Currency(description: "EUR")))})),
                 .init(type: .currency,
                       mainImg: ("", Image("Flag CHF")),
                       title: "CHF",
                       subtitle: "Франк",
                       action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Item(code: Currency(description: "CHF")))},
                       topDashboard: .init(kindImage: .down, valueText: "64,89", type: .buy, action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Buy(code: Currency(description: "CHF")))}),
                       bottomDashboard: .init(kindImage: .up, valueText: "65,09", type: .sell, action: { [weak self] in
                                        self?.action.send(MainSectionViewModelAction
                                                            .CurrencyMetall
                                                            .DidTapped.Sell(code: Currency(description: "CHF")))}))]
    }
    
}

extension MainSectionCurrencyMetallView.ViewModel {

    static var sample: MainSectionCurrencyMetallView.ViewModel =
        .init(
           content: .items(
               [.init(type: .currency,
                      mainImg: ("0",Image("Flag USD")),
                      title: "USD",
                      subtitle: "Доллар",
                      action: {},
                      topDashboard: .init(kindImage: .down, valueText: "68,19", type: .buy, action: {}),
                      bottomDashboard: .init(kindImage: .up, valueText: "69,45", type: .sell, action: {} )),
               .init(type: .currency,
                     mainImg: ("1", nil),
                     title: "EUR",
                     subtitle: "Евро",
                     action: {},
                     topDashboard: .init(kindImage: .up, valueText: "69,23", type: .buy, action: {}),
                     bottomDashboard: .init(kindImage: .no, valueText: "70,01", type: .sell, action: {})),
               .init(type: .currency,
                     mainImg: ("2", Image("Flag CHF")),
                     title: "CHF",
                     subtitle: "Франк",
                     action: {},
                     topDashboard: .init(kindImage: .down, valueText: "64,89", type: .buy, action: {}),
                     bottomDashboard: .init(kindImage: .up, valueText: "65,09", type: .sell, action: {}))]),
           selector: nil,
           isCollapsed: false)

}
