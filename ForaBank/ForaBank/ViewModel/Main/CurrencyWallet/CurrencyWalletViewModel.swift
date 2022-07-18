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
    
    let title = "Обмен валют"

    init(listViewModel: CurrencyListView.ViewModel,
         swapViewModel: CurrencySwapView.ViewModel,
         selectorViewModel: CurrencySelectorView.ViewModel,
         action: @escaping () -> Void) {

        self.listViewModel = listViewModel
        self.swapViewModel = swapViewModel
        self.selectorViewModel = selectorViewModel
        self.backButton = .init(icon: .ic24ChevronLeft, action: action)
    }
}

extension CurrencyWalletViewModel {
    
    struct NavigationButtonViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let action: () -> Void
    }
}
