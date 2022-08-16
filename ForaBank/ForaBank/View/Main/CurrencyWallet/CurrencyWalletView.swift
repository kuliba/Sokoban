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

        VStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 24) {
                    
                    ForEach(viewModel.items, id: \.id) { viewModel in
                        
                        switch viewModel {
                        case let listViewModel as CurrencyListView.ViewModel:
                            CurrencyListView(viewModel: listViewModel)
                            
                        case let swapViewModel as CurrencySwapView.ViewModel:
                            CurrencySwapView(viewModel: swapViewModel)
                            
                        case let selectorViewModel as CurrencySelectorView.ViewModel:
                            CurrencySelectorView(viewModel: selectorViewModel)
                            
                        case let confirmationViewModel as CurrencyExchangeConfirmationView.ViewModel:
                            CurrencyExchangeConfirmationView(viewModel: confirmationViewModel)
                            
                        case let successViewModel as CurrencyExchangeSuccessView.ViewModel:
                            CurrencyExchangeSuccessView(viewModel: successViewModel)
                            
                        default:
                            Color.clear
                        }
                    }
                }
            }
            
            switch viewModel.state {
            case .button:
                
                ButtonSimpleView(viewModel: viewModel.continueButton)
                    .frame(height: 48)
                    .padding(.horizontal, 20)
                    .padding(.vertical, viewModel.verticalPadding)
                
            case .spinner:
                
                SpinnerRefreshView(icon: viewModel.icon)
                    .padding(.vertical, viewModel.verticalPadding)
            }
        }
        .ignoreKeyboard()
        .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: viewModel.backButton.action) {
            viewModel.backButton.icon
                .renderingMode(.template)
                .foregroundColor(.iconBlack)
        })
        .alert(item: $viewModel.alert) { alert in
            Alert(with: alert)
        }
        .onTapGesture {
            
            viewModel.resetCurrencySwap()
            UIApplication.shared.endEditing()
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Previews

struct CurrencyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyWalletView(viewModel: .init(
            .emptyMock,
            currency: .rub,
            currencyItem: .init(
                icon: nil,
                currency: .rub,
                rateBuy: "1,00",
                rateSell: "64,50"),
            currencyOperation: .buy,
            currencySymbol: "₽") {})
    }
}
