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
    
    let listViewModel: CurrencyListView.ViewModel
    let swapViewModel: CurrencySwapView.ViewModel
    let selectorViewModel: CurrencySelectorView.ViewModel
    let backButton: NavigationButtonViewModel
    
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
    
    init(_ model: Model, items: [CurrencyWalletItem], state: ButtonActionState = .button, listViewModel: CurrencyListView.ViewModel, swapViewModel: CurrencySwapView.ViewModel, selectorViewModel: CurrencySelectorView.ViewModel, action: @escaping () -> Void) {
        
        self.model = model
        self.items = items
        self.state = state
        self.listViewModel = listViewModel
        self.swapViewModel = swapViewModel
        self.selectorViewModel = selectorViewModel
        
        backButton = .init(icon: .ic24ChevronLeft, action: action)
        buttonStyle = .red
        
        bind()
    }
    
    convenience init(_ model: Model, state: ButtonActionState = .button, listViewModel: CurrencyListView.ViewModel, swapViewModel: CurrencySwapView.ViewModel, selectorViewModel: CurrencySelectorView.ViewModel, action: @escaping () -> Void) {
        
        self.init(model,
                  items: [listViewModel, swapViewModel],
                  state: state,
                  listViewModel: listViewModel,
                  swapViewModel: swapViewModel,
                  selectorViewModel: selectorViewModel,
                  action: action)
        
        bind()
    }
    
    private func bind() {
        
        listViewModel.$currency
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currency in
                
                swapViewModel.currency = currency
                
            }.store(in: &bindings)
        
        $buttonStyle
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] buttonStyle in
                
                continueButton.style = buttonStyle
                
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
    
    private func appendSelectorViewIfNeeds() {
        
        let selectorViewModel = items.first(where: { $0 is CurrencySelectorView.ViewModel })
        
        if selectorViewModel == nil {
            
            let productAccounts = model.products.value[.account]
            var selectorState: CurrencySelectorView.ViewModel.State = .productSelector
            
            if productAccounts == nil {
                
                buttonStyle = .inactive
                selectorState = .openAccount
            }
            
            let selectorViewModel: CurrencySelectorView.ViewModel = .init(model, state: selectorState)
            
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
