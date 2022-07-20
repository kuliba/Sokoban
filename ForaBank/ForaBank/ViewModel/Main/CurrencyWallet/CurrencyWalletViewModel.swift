//
//  CurrencyWalletViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 05.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

class CurrencyWalletViewModel: ObservableObject {

    let listViewModel: CurrencyListView.ViewModel
    let swapViewModel: CurrencySwapView.ViewModel
    let selectorViewModel: CurrencySelectorView.ViewModel
    let backButton: NavigationButtonViewModel
    let continueButton: ButtonSimpleView.ViewModel
    
    let title = "Обмен валют"
    
    private var bindings = Set<AnyCancellable>()

    init(listViewModel: CurrencyListView.ViewModel,
         swapViewModel: CurrencySwapView.ViewModel,
         selectorViewModel: CurrencySelectorView.ViewModel,
         action: @escaping () -> Void) {

        self.listViewModel = listViewModel
        self.swapViewModel = swapViewModel
        self.selectorViewModel = selectorViewModel
        self.backButton = .init(icon: .ic24ChevronLeft, action: action)
        continueButton = .init(title: "Продолжить", style: .red) {}
        
        bind()
    }
    
    private func bind() {
        
        listViewModel.$currencyType
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currencyType in
                
                swapViewModel.currencyType = currencyType
                
            }.store(in: &bindings)
    }
}

extension CurrencyWalletViewModel {
    
    struct NavigationButtonViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let action: () -> Void
    }
}
