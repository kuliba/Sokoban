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
            CurrencySelectorView(viewModel: viewModel.selectorViewModel)
        }
        .ignoreKeyboard()
        .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: viewModel.backButton.action) {
            viewModel.backButton.icon
                .renderingMode(.template)
                .foregroundColor(.iconBlack)
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// MARK: - Previews

struct CurrencyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyWalletView(viewModel: .init(
            listViewModel: .sample,
            swapViewModel: .sample,
            selectorViewModel: .sample) {})
    }
}
