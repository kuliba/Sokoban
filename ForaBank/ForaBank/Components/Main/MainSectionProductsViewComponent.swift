//
//  MainSectionProductsViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension MainSectionProductsView {
    
    class ViewModel: MainSectionCollapsableViewModel {
        
        override var type: MainSectionType { .products }
        @Published var productsTypeSelector: OptionSelectorViewModel?
        @Published var products: [MainSectionProductsListItemViewModel]
        let moreButton: MoreButtonViewModel
        
        internal init(productsTypeSelector: OptionSelectorViewModel?, products: [MainSectionProductsListItemViewModel], moreButton: MoreButtonViewModel, isCollapsed: Bool) {
            
            self.productsTypeSelector = productsTypeSelector
            self.products = products
            self.moreButton = moreButton
            super.init(isCollapsed: isCollapsed)
        }
        
        struct MoreButtonViewModel {
            
            let icon: Image
            let action: () -> Void
        }
    }
}

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            VStack {
                
                if let productSelectorViewModel = viewModel.productsTypeSelector {
                    
                    OptionSelectorView(viewModel: productSelectorViewModel)
                        .frame(height: 24)
                        .padding(.top, 12)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 8) {
                        
                        ForEach(viewModel.products) { itemViewModel in
                            
                            switch itemViewModel {
                            case let cardViewModel as ProductView.ViewModel:
                                ProductView(viewModel: cardViewModel)
                                
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
            
        }
        .overlay(MoreButtonView(viewModel: viewModel.moreButton))
    }
    
    struct MoreButtonView: View {
        
        let viewModel: ViewModel.MoreButtonViewModel
        
        var body: some View {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: viewModel.action){
                        
                        ZStack{
                            
                            Circle()
                                .frame(width: 32, height: 32, alignment: .center)
                                .foregroundColor(.mainColorsGrayLightest)
                            
                            viewModel.icon
                                .renderingMode(.original)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

//MARK: - Preview

struct MainBlockProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionProductsView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionProductsView.ViewModel {
    
    static let sample = MainSectionProductsView.ViewModel(productsTypeSelector: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета")], selected: "0", style: .products), products: [ProductView.ViewModel.classic, ProductView.ViewModel.classic], moreButton: .init(icon: .ic24MoreHorizontal, action: {}), isCollapsed: false)
    
}
