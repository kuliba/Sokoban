//
//  CurrencyWalletView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 05.07.2022.
//

import SwiftUI

// MARK: - View

struct CurrencyWalletView: View {

    @ObservedObject var viewModel: CurrencyWalletViewModel

    var body: some View {

        ScrollView(showsIndicators: false) {

            CurrencyListView(viewModel: viewModel.listViewModel)
            CurrencySwapView(viewModel: viewModel.swapViewModel)
        }
    }
}

// MARK: - Previews

struct CurrencyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyWalletView(viewModel: .init(
            listViewModel: .sample,
            swapViewModel: .sample))
    }
}
