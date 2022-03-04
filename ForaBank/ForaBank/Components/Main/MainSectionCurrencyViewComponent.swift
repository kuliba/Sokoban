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
        
        let item: CurrencyExchangeView.ViewModel
        let title: String
        
        internal init(item: CurrencyExchangeView.ViewModel, title: String, isCollapsed: Bool) {
            
            self.item = item
            self.title = title
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct MainSectionCurrencyView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack(spacing: 0) {
            
            Button {

                viewModel.isCollapsed.toggle()

            } label: {

                HStack {

                    Text(viewModel.title)
                        .font(.textH2SB20282())
                        .foregroundColor(.textSecondary)

                    if viewModel.isCollapsed {
                        Image.ic24ChevronUp
                            .foregroundColor(.iconGray)
                    } else {
                        Image.ic24ChevronDown
                            .foregroundColor(.iconGray)
                    }

                    Spacer()
                }
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)

            if !viewModel.isCollapsed {
                CurrencyExchangeView(viewModel: viewModel.item)
            }
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
    
    static let sample = MainSectionCurrencyView.ViewModel(item: .sample,
                                                                title: "Обмен валют",
                                                                isCollapsed: false)

}
