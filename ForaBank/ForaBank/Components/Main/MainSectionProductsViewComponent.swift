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
        
        internal init(productsTypeSelector: OptionSelectorViewModel?, products: [MainSectionProductsListItemViewModel], isCollapsed: Bool) {
            
            self.productsTypeSelector = productsTypeSelector
            self.products = products
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct MainSectionProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {

            HeaderView(viewModel: viewModel)
            
            if let productSelectorViewModel = viewModel.productsTypeSelector {
                
                OptionSelectorView(viewModel: productSelectorViewModel)
                    .frame(height: 24)
                    .padding(.top, 12)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                            
                        HStack {

                            ForEach(viewModel.products) { itemViewModel in
                                
                                switch itemViewModel {
                                case let cardViewModel as MainCardComponentView.ViewModel:
                                    MainCardComponentView(viewModel: cardViewModel)
                                    
                                default:
                                    EmptyView()
                                }
                        }
            }
            
            Spacer()
        }
    }
    }
    
    struct HeaderView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {

            HStack(alignment: .center) {
                
                Text(viewModel.title)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                
                Button {
                    
                } label: {
                        
                    Image.ic24ChevronDown
                        .renderingMode(.original)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button {
                    
                } label: {

                    ZStack{
                        Image.ic24MoreHorizontal
                            .renderingMode(.original)
                    }
                    .frame(width: 32, height: 32, alignment: .center)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(90)

                }
            }
            .padding([.leading, .trailing], 20)
            .padding(.bottom, 8)
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
    
    static let sample = MainSectionProductsView.ViewModel(productsTypeSelector: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета")], selected: "0", style: .products), products: [MainCardComponentView.ViewModel.classic], isCollapsed: false)
    
}
