//
//  CurrencyWalletViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 05.07.2022.
//

import SwiftUI
import Combine

protocol CurrencyWalletItem: Hashable {}

// MARK: - ViewModel

class CurrencyWalletViewModel: ObservableObject {
    
    @Published var state: ButtonActionState

    let listViewModel: CurrencyListView.ViewModel
    let swapViewModel: CurrencySwapView.ViewModel
    let selectorViewModel: CurrencySelectorView.ViewModel
    let backButton: NavigationButtonViewModel
    
    lazy var continueButton: ButtonSimpleView.ViewModel = .init(title: "Продолжить", style: .red) { [weak self] in

        guard let self = self else { return }
        
        self.state = .spinner
        self.model.action.send(ModelAction.Products.Update.Fast.All())
    }
    
    let model: Model
    let title = "Обмен валют"
    
    private var bindings = Set<AnyCancellable>()
    
    enum ButtonActionState {
        
        case button
        case spinner
    }

    init(_ model: Model,
         state: ButtonActionState = .button,
         listViewModel: CurrencyListView.ViewModel,
         swapViewModel: CurrencySwapView.ViewModel,
         selectorViewModel: CurrencySelectorView.ViewModel,
         action: @escaping () -> Void) {

        self.model = model
        self.state = state
        self.listViewModel = listViewModel
        self.swapViewModel = swapViewModel
        self.selectorViewModel = selectorViewModel
        self.backButton = .init(icon: .ic24ChevronLeft, action: action)
        
        bind()
    }
    
    private func bind() {
        
        listViewModel.$currencyType
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currencyType in
                
                swapViewModel.currencyType = currencyType
                
            }.store(in: &bindings)
    }
    
    func resetCurrencySwap() {
        
        let currencySwap = swapViewModel.currencySwap
        let сurrencyCurrentSwap = swapViewModel.сurrencyCurrentSwap
        
        currencySwap.action.send(CurrencySwapAction.TextField.Done(currencyAmount: currencySwap.currencyAmount))
        сurrencyCurrentSwap.action.send(CurrencySwapAction.TextField.Done(currencyAmount: сurrencyCurrentSwap.currencyAmount))
    }
}

extension CurrencyWalletViewModel {
    
    struct NavigationButtonViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let action: () -> Void
    }
}
