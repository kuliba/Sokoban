//
//  CurrencyWalletViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 05.07.2022.
//

import Combine

// MARK: - ViewModel

class CurrencyWalletViewModel: ObservableObject {

    let listViewModel: CurrencyListView.ViewModel
    let swapViewModel: CurrencySwapView.ViewModel

    init(listViewModel: CurrencyListView.ViewModel,
         swapViewModel: CurrencySwapView.ViewModel) {

        self.listViewModel = listViewModel
        self.swapViewModel = swapViewModel
    }
}
