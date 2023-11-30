//
//  OpenDepositListView.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import SwiftUI
import ScrollViewProxy

struct OpenDepositListView: View {
    
    @ObservedObject var viewModel: OpenDepositListViewModel
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(viewModel.offers, content: offerProductView)
            }
            .foregroundColor(.black)
            .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
                
                switch bottomSheet.type {
                case let .openDeposit(additionalCondition):
                    OfferProductView.DetailConditionView(viewModel: additionalCondition)
                }
            }
        }
        .navigationBarTitle(viewModel.navigationBar.title, displayMode: .inline)
        .ignoresSafeArea()
        .navigationBar(with: viewModel.navigationBar)
    }
    
    private func offerProductView(
        offer: OfferProductView.ViewModel
    ) -> some View {
        
        OfferProductView(viewModel: offer)
    }
}

struct OpenDepositView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OpenDepositListView(
            viewModel: .init(
                navigationBar: .init(title: "Вклады"),
                products: [.depositSample, .depositSample],
                catalogType: .deposit
            )
        )
    }
}
