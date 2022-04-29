//
//  OpenDepositView.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import SwiftUI
import ScrollViewProxy

struct OpenDepositView: View {
    
    @ObservedObject var viewModel: OpenDepositViewModel
    
    var body: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.products) { productCard in
                    switch viewModel.style {
                    case .deposit:
                        OfferProductView(viewModel: productCard)
                        
                    case .catalog:
                        OfferProductView(viewModel: productCard)
                    }
                }
            }
        }
    }
}

struct OpenDepositView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView(viewModel: .sample)
    }
}

extension OpenDepositViewModel {
    
    static let sample = MainViewModel(sections: [MainSectionProductsView.ViewModel.sample, MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample], isRefreshing: true)
    
    static let sampleProducts = MainViewModel(sections: [MainSectionProductsView.ViewModel(.productsMock), MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample], isRefreshing: false)
}
