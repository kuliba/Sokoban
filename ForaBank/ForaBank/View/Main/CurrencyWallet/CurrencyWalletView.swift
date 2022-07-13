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
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                VStack(spacing: 20) {
                    
                    ProductCardView(viewModel: .sample1)
                    ProductCardView(viewModel: .sample3)
                    
                }.padding(.vertical, 20)
                
            }.padding(20)
        }
        .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: viewModel.backButton.action) {
            viewModel.backButton.icon
                .renderingMode(.template)
                .foregroundColor(.iconBlack)
        })
    }
}

// MARK: - Previews

struct CurrencyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyWalletView(viewModel: .init(
            listViewModel: .sample,
            swapViewModel: .sample,
            action: {}))
    }
}
