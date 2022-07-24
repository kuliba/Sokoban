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
                
                ForEach(viewModel.items, id: \.id) { viewModel in
                    
                    switch viewModel {
                    case let listViewModel as CurrencyListView.ViewModel:
                        CurrencyListView(viewModel: listViewModel)

                    case let swapViewModel as CurrencySwapView.ViewModel:
                        CurrencySwapView(viewModel: swapViewModel)
                        
                    case let selectorViewModel as CurrencySelectorView.ViewModel:
                        CurrencySelectorView(viewModel: selectorViewModel)

                    default:
                        Color.clear
                    }
                }
            }
            
            switch viewModel.state {
            case .button:
                
                ButtonSimpleView(viewModel: viewModel.continueButton)
                    .frame(height: 48)
                    .padding(20)
                
            case .spinner:
                
                SpinnerRefreshView(icon: viewModel.icon)
                    .padding(.bottom, 20)
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
        .onTapGesture {
            
            viewModel.resetCurrencySwap()
            UIApplication.shared.endEditing()
        }
        .padding(.vertical, 20)
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Previews

struct CurrencyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyWalletView(viewModel: .init(
            .emptyMock,
            listViewModel: .sample,
            swapViewModel: .sample,
            selectorViewModel: .sample) {})
    }
}
