//
//  MainView.swift
//  ForaBank
//
//  Created by Max Gribov on 05.03.2022.
//

import SwiftUI
import ScrollViewProxy

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.isRefreshing == true {
                    
                    RefreshView()
                }
                
                ScrollView(showsIndicators: false) {
                    
                    ScrollViewReader { proxy in
                        
                        VStack(spacing: 20) {
                            
                            ForEach(viewModel.sections) { section in
                                
                                switch section {
                                case let productsSectionViewModel as MainSectionProductsView.ViewModel:
                                    MainSectionProductsView(viewModel: productsSectionViewModel)
                                    
                                case let fastOperationViewModel as MainSectionFastOperationView.ViewModel:
                                    MainSectionFastOperationView(viewModel: fastOperationViewModel)
                                    
                                case let promoViewModel  as MainSectionPromoView.ViewModel:
                                    MainSectionPromoView(viewModel: promoViewModel)
                                    
                                case let currencyViewModel as MainSectionCurrencyView.ViewModel:
                                    MainSectionCurrencyView(viewModel: currencyViewModel)
                                    
                                case let openProductViewModel as MainSectionOpenProductView.ViewModel:
                                    MainSectionOpenProductView(viewModel: openProductViewModel)
                                    
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    
                }
                .padding(20)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView(viewModel: .sample)
    }
}

extension MainViewModel {
    
    static let sample = MainViewModel(sections: [MainSectionProductsView.ViewModel.sample, MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample], isRefreshing: true)
    
    static let sampleProducts = MainViewModel(sections: [MainSectionProductsView.ViewModel(.productsMock), MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample], isRefreshing: false)
}
