//
//  MyProductsMoneyViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//  Full refactored by Dmitry Martynov on 20.08.2022
//

import Combine
import SwiftUI

class MyProductsMoneyViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var balanceVM: BalanceViewModel
    @Published var currencyButtonVM: CurrencyButtonViewModel
    
    let allMoneyTitle: String = "Всего денег"
    let cbRateTitle: String = "По курсу ЦБ"
    
    private var bindings = Set<AnyCancellable>()
    private let model: Model
    
    init(balanceVM: BalanceViewModel,
         currencyButtonVM: CurrencyButtonViewModel,
         model: Model) {
        
        self.balanceVM = balanceVM
        self.currencyButtonVM = currencyButtonVM
        self.model = model
    }
    
    init(model: Model) {
        
        self.model = model
        self.balanceVM = .placeholder
        self.currencyButtonVM = .init(currencySymbol: model.settingsProductsMoney.selectedCurrencySymbol,
                                      state: .disabled,
                                      model: model)
        updateBalance(isUpdating: false,
                      products: model.allProducts,
                      rates: model.centralBankRates.value,
                      selectedCurrency: (model.settingsProductsMoney.selectedCurrencyId,
                                         model.settingsProductsMoney.selectedCurrencySymbol))

        bind()
        bind(currencyButtonVM)
    }
    
    enum BalanceViewModel {
        case balanceTitle(String)
        case placeholder
        
        var isSingleLineView: Bool {
            
            switch self {
            case .placeholder: return true
            case let .balanceTitle(formattedStr):
                
                let count = formattedStr.count
                
                switch UIScreen.main.bounds.width {
                case ..<280,
                    280...320 where count > 9,
                    320...360 where count > 11,
                    360...375 where count > 13,
                    375...390 where count > 14,
                    390...414 where count > 16,
                    414...428 where count > 17:
                    return false
                default:
                    return true
                }
            }
        }
    }
    
    class CurrencyButtonViewModel: ObservableObject {
            
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var state: State
        @Published var currencySymbol: String
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
         
        var selectedCurrency: String { model.settingsProductsMoney.selectedCurrencyId }
        
        init(currencySymbol: String, state: State, model: Model) {
                
            self.currencySymbol = currencySymbol
            self.state = state
            self.model = model
            
            bind()
        }
        
        enum State {
            case disabled
            case enabled
            case expanded([CurrencyItemViewModel])
            
            var isDisable: Bool {
                if case .disabled = self { return true }
                else { return false }
            }
        }
    
        class CurrencyItemViewModel: Identifiable {
        
            let id: String
            let symbol: String
            let name: String
            let rate: Double
            let isSelected: Bool
            let action: () -> Void
        
            var rateFormatted: String {
                id == "RUB" ? "1 \(symbol) - 1 \u{20BD}"
                            : "1 \(symbol) - \(String(format: "%.4f", rate)) \u{20BD}"
            }
        
            init(id: String, symbol: String, name: String, rate: Double, isSelected: Bool,
                 action: @escaping () -> Void) {
            
                self.id = id
                self.symbol = symbol
                self.name = name
                self.rate = rate
                self.isSelected = isSelected
                self.action = action
            }
        }
        
        var rubItem: CurrencyItemViewModel {
        
                .init(id: "RUB",
                      symbol: "\u{20BD}",
                      name: "Российский рубль",
                      rate: 1,
                      isSelected: self.selectedCurrency == "RUB",
                      action: { [unowned self] in
                    self.action.send(CurrencyButtonViewModelAction.CurrencySelected(id: "RUB", symbol: "\u{20BD}" )) })
        }
        
        static func getUnicode(_ value: String) -> String {
            value.applyingTransform(.init("Hex/Unicode-Any"), reverse: false) ?? ""
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as CurrencyButtonViewModelAction.ButtonTapped:
                        
                        switch state {
                        case .enabled:
                            
                            withAnimation {
                                state = .expanded(reduce(rates: model.centralBankRates.value,
                                                         currency: selectedCurrency))
                            }
                        case .expanded:
                            
                            withAnimation {
                                state = .enabled
                            }
                        default: break
                        }
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
        }
        
        private func reduce(rates: [CentralBankRatesData], currency: String) -> [CurrencyItemViewModel] {
            
            var items = rates.map { item in
                CurrencyItemViewModel(id: item.letterCode,
                                      symbol: Self.getUnicode(item.unicode),
                                      name: item.name,
                                      rate: item.rate,
                                      isSelected: currency == item.id,
                                      action: { [weak self] in
                                                self?.action.send(CurrencyButtonViewModelAction
                                                                .CurrencySelected(id: item.letterCode,
                                                                                  symbol: Self.getUnicode(item.unicode))) })
            }
            
            items.insert(self.rubItem, at: 0)
            return items
        }
    }

    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as MyProductsMoneyViewModelAction.ViewDidApear:
                    
                    model.action.send(ModelAction.Dictionary.UpdateCache
                        .Request(type: .centralBanksRates, serial: nil))
                    
                default:
                    break
                }
        }.store(in: &bindings)
        
        model.dictionariesUpdating
            .combineLatest(model.productsUpdating)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
            
                let dictUpdatingSet = data.0
                let productsUpdating = data.1
                
                updateBalance(isUpdating: dictUpdatingSet.contains(.centralBanksRates)
                                            || !productsUpdating.isEmpty,
                              products: model.allProducts,
                              rates: model.centralBankRates.value,
                              selectedCurrency: (model.settingsProductsMoney.selectedCurrencyId,
                                                 model.settingsProductsMoney.selectedCurrencySymbol))
        }
        .store(in: &bindings)
        
        model.products
            .combineLatest(model.centralBankRates)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] products, rates in

                let isUpdating = model.dictionariesUpdating.value.contains(.centralBanksRates) || model.productsUpdating.value.isEmpty == false
                updateBalance(isUpdating: isUpdating,
                              products: model.allProducts,
                              rates: rates,
                              selectedCurrency: (model.settingsProductsMoney.selectedCurrencyId,
                                                 model.settingsProductsMoney.selectedCurrencySymbol))
        }
        .store(in: &bindings)
    }
    
    private func bind(_ currencyButtonVM: CurrencyButtonViewModel ) {
        
        currencyButtonVM.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as CurrencyButtonViewModelAction.CurrencySelected:
                    
                    model.settingsProductsMoneyUpdate(.init(selectedCurrencyId: payload.id,
                                                            selectedCurrencySymbol: payload.symbol))
                    
                    updateBalance(products: model.allProducts,
                                  rates: model.centralBankRates.value,
                                  selectedCurrency: (model.settingsProductsMoney.selectedCurrencyId,
                                                     model.settingsProductsMoney.selectedCurrencySymbol))
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    private func updateBalance(isUpdating: Bool = false,
                               products: [ProductData],
                               rates: [CentralBankRatesData],
                               selectedCurrency: (id: String, symbol: String)) {
        
        if isUpdating {
            
            withAnimation {
                
                self.balanceVM = .placeholder
                self.currencyButtonVM.state = .disabled
            }
            
        } else {
            
            let filter = ProductData.Filter(rules: [ProductData.Filter.ProductTypeRule([.card, .account, .deposit]),
                                                    ProductData.Filter.CardAdditionalOwnedRestrictedRule(),
                                                    ProductData.Filter.CardAdditionalNotOwnedRestrictedRule()])
            
            let filteredProducts = filter.filteredProducts(products)
            let balanceRub = filteredProducts.compactMap({ $0.balanceRub }).reduce(0, +)
            
            if let currencyDataItem = rates.first(where: { $0.id == selectedCurrency.id }) {
            
                withAnimation {
                    
                    self.balanceVM = .balanceTitle(Self.doubleFormatter(balanceRub / currencyDataItem.rate))
                    self.currencyButtonVM.currencySymbol = selectedCurrency.symbol
                    self.currencyButtonVM.state = .enabled
                }
                
            } else {
                
                self.model.settingsProductsMoneyUpdate(.init(
                    selectedCurrencyId: "RUB", selectedCurrencySymbol: "\u{20BD}"))
                
                withAnimation {
                   
                    self.balanceVM = .balanceTitle(Self.doubleFormatter(balanceRub))
                    self.currencyButtonVM.state = .enabled
                    self.currencyButtonVM.currencySymbol = "\u{20BD}"
                }
            }
        }
    }
    
    static func doubleFormatter(_ value: Double) -> String {
        
        NumberFormatter.decimal().string(from: NSNumber(value: value)) ?? ""
    }
    
}
    
enum MyProductsMoneyViewModelAction {
    
    struct ViewDidApear: Action {}
}

enum CurrencyButtonViewModelAction {
    
    struct ButtonTapped: Action {}
    
    struct CurrencySelected: Action {

        let id: CentralBankRatesData.ID
        let symbol: String
    }
}

extension MyProductsMoneyViewModel {
    
    static let currencyItems: [CurrencyButtonViewModel.CurrencyItemViewModel] = [
        .init(id: "USD", symbol: "\u{0024}", name: "Доллар США", rate: 60.54, isSelected: false, action: {}),
        .init(id: "EUR", symbol: "\u{20AC}", name: "Евро", rate: 61.22, isSelected: false, action: {}),
        .init(id: "GBP", symbol: "\u{00A3}", name: "Фунты стерлингов", rate: 71.7, isSelected: false, action: {}),
        .init(id: "CHF", symbol: "\u{20A3}", name: "Швейцарские франки", rate: 68.8, isSelected: false, action: {}),
        .init(id: "CHF", symbol: "\u{20A3}", name: "Швейцарские франки", rate: 68.8, isSelected: false, action: {})
    ]
}
    
extension MyProductsMoneyViewModel {
        
    static let samplePlaceholder: MyProductsMoneyViewModel =
        .init(balanceVM: .placeholder,
              currencyButtonVM: .init(currencySymbol: "\u{20BD}", state: .disabled, model: Model.emptyMock),
              model: .emptyMock)
    
    static let sampleBalance: MyProductsMoneyViewModel =
         
        .init(balanceVM: .balanceTitle(MyProductsMoneyViewModel.doubleFormatter(2817239873.05)),
              currencyButtonVM: .init(currencySymbol: "\u{20BD}", state: .enabled, model: Model.emptyMock),
              model: .emptyMock)
  
    static let sampleExpanded: MyProductsMoneyViewModel = {
       
        let currencyButtonVM: MyProductsMoneyViewModel.CurrencyButtonViewModel =
                                .init(currencySymbol: "\u{20BD}", state: .enabled, model: Model.emptyMock)
        
        currencyButtonVM.state = .expanded([currencyButtonVM.rubItem] + MyProductsMoneyViewModel.currencyItems)
        
        return MyProductsMoneyViewModel(
                            balanceVM: .balanceTitle(MyProductsMoneyViewModel.doubleFormatter(581239873.2)),
                            currencyButtonVM: currencyButtonVM,
                            model: .emptyMock)
    }()
}
