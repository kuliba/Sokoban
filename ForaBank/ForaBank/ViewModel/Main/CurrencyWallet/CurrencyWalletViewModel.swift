//
//  CurrencyWalletViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 05.07.2022.
//

import SwiftUI
import Combine

protocol CurrencyWalletItem {
    
    var id: String { get }
}

// MARK: - ViewModel

class CurrencyWalletViewModel: ObservableObject {
    
    @Published var items: [CurrencyWalletItem]
    @Published var state: ButtonActionState
    @Published var buttonStyle: ButtonSimpleView.ViewModel.ButtonStyle

    private let currency: Currency
    private let currencyItem: CurrencyItemViewModel
    private let currencyOperation: CurrencyOperation
    private let currencySymbol: String
    
    let backButton: NavigationButtonViewModel
    
    private lazy var listViewModel: CurrencyListView.ViewModel = makeListViewModel()
    private lazy var swapViewModel: CurrencySwapView.ViewModel = makeSwapViewModel()
    private var selectorViewModel: CurrencySelectorView.ViewModel?
    
    lazy var continueButton: ButtonSimpleView.ViewModel = .init(title: "Продолжить", style: buttonStyle) { [weak self] in
        
        guard let self = self else { return }
        
        self.appendSelectorViewIfNeeds()
        self.model.action.send(ModelAction.Products.Update.Fast.All())
    }
    
    let model: Model
    let title = "Обмен валют"
    let icon: Image = .init("Logo Fora Bank")
    
    private var bindings = Set<AnyCancellable>()
    
    enum ButtonActionState {
        
        case button
        case spinner
    }
    
    init(_ model: Model, currency: Currency, currencyItem: CurrencyItemViewModel, currencyOperation: CurrencyOperation, currencySymbol: String, items: [CurrencyWalletItem], state: ButtonActionState, action: @escaping () -> Void) {
        
        self.model = model
        self.currency = currency
        self.currencyItem = currencyItem
        self.currencyOperation = currencyOperation
        self.currencySymbol = currencySymbol
        self.items = items
        self.state = state
        
        backButton = .init(icon: .ic24ChevronLeft, action: action)
        buttonStyle = .red
    }
    
    convenience init(_ model: Model, currency: Currency, currencyItem: CurrencyItemViewModel, currencyOperation: CurrencyOperation, currencySymbol: String, state: ButtonActionState = .button, action: @escaping () -> Void) {
        
        self.init(model, currency: currency, currencyItem: currencyItem, currencyOperation: currencyOperation, currencySymbol: currencySymbol, items: .init(), state: state, action: action)
        
        bind()
    }
    
    private func bind() {
       
        items = [listViewModel, swapViewModel]
        
        listViewModel.$currency
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currency in
                
                swapViewModel.currency = currency
                
                if let selectorViewModel = selectorViewModel {
                    selectorViewModel.currency = currency
                }
            }.store(in: &bindings)
        
        $buttonStyle
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] buttonStyle in
                
                continueButton.style = buttonStyle
                
            }.store(in: &bindings)
        
        swapViewModel.$currencyOperation
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currencyOperation in
                
                if let selectorViewModel = selectorViewModel {
                    
                    if #available(iOS 14.0, *) {

                        withAnimation {
                            selectorViewModel.currencyOperation = currencyOperation
                        }
                    }
                }
            }.store(in: &bindings)
    }
    
    func resetCurrencySwap() {
        
        let currencySwap = swapViewModel.currencySwap
        let сurrencyCurrentSwap = swapViewModel.сurrencyCurrentSwap
        
        if currencySwap.textField.isEditing == true {
            currencySwap.action.send(CurrencySwapAction.TextField.Update(currencyAmount: currencySwap.currencyAmount))
        } else {
            сurrencyCurrentSwap.action.send(CurrencySwapAction.TextField.Update(currencyAmount: сurrencyCurrentSwap.currencyAmount))
        }
    }
    
    private func makeListViewModel() -> CurrencyListView.ViewModel {
        .init(model, currency: currency)
    }
    
    private func makeSwapViewModel() -> CurrencySwapView.ViewModel {
        
        let currencyRate = currencyOperation == .buy ? currencyItem.rateBuy : currencyItem.rateSell
        let currencyAmount = NumberFormatter.decimal(currencyRate) ?? 0
        let image = model.images.value[currencyItem.iconId]?.image
        
        return .init(
            model,
            currencySwap: .init(
                icon: image,
                currencyAmount: 1.00,
                currency: currency),
            сurrencyCurrentSwap: .init(
                icon: .init("Flag RUB"),
                currencyAmount: currencyAmount,
                currency: Currency(description: "RUB")),
            currencyOperation: currencyOperation,
            currency: currency,
            currencyRate: currencyAmount,
            quotesInfo: "1\(currencySymbol) = \(currencyRate) ₽")
    }
    
    private func makeSelectorViewModel() -> CurrencySelectorView.ViewModel {
        
        let productAccounts = model.products.value[.account]
        var selectorState: CurrencySelectorView.ViewModel.State = .productSelector
        
        if productAccounts == nil {
            
            buttonStyle = .inactive
            selectorState = .openAccount
        }
        
        return .init(model, state: selectorState, currency: currency, currencyOperation: currencyOperation)
    }
    
    private func appendSelectorViewIfNeeds() {
        
        if selectorViewModel == nil {
            
            let selectorViewModel = makeSelectorViewModel()
            self.selectorViewModel = selectorViewModel
            
            withAnimation {
                items.append(selectorViewModel)
            }
        }
    }
}

extension CurrencyWalletViewModel {
    
    struct NavigationButtonViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let action: () -> Void
    }
}
