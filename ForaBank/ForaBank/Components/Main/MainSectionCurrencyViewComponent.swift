//
//  MainSectionCurrencyViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainSectionCurrencyView {

    class ViewModel: MainSectionCollapsableViewModel {
        
        override var type: MainSectionType { .currencyExchange }
        let currencyExchange: CurrencyExchangeView.ViewModel
        
        internal init(currencyExchange: CurrencyExchangeView.ViewModel, isCollapsed: Bool) {
            
            self.currencyExchange = currencyExchange
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct MainSectionCurrencyView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            CurrencyExchangeView(viewModel: viewModel.currencyExchange)
        }
    }
}

//MARK: - Preview

struct MainBlockCurrencyExchangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionCurrencyView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionCurrencyView.ViewModel {
    
    static let sample = MainSectionCurrencyView.ViewModel(currencyExchange: .sample, isCollapsed: false)

}
