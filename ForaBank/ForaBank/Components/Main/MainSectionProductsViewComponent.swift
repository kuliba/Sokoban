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
        @Published var typeSelector: OptionSelectorViewModel?
        @Published var items: [MainSectionProductsListItemViewModel]
        let moreButton: MoreButtonViewModel
        
        internal init(productsTypeSelector: OptionSelectorViewModel?, products: [MainSectionProductsListItemViewModel], moreButton: MoreButtonViewModel, isCollapsed: Bool) {
            
            self.typeSelector = productsTypeSelector
            self.items = products
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
            
            VStack(spacing: 16) {
                
                if let productSelectorViewModel = viewModel.typeSelector {
                    
                    OptionSelectorView(viewModel: productSelectorViewModel)
                        .frame(height: 24)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 8) {
                        
                        ForEach(viewModel.items) { itemViewModel in
                            
                            switch itemViewModel {
                            case let cardViewModel as ProductView.ViewModel:
                                ProductView(viewModel: cardViewModel)
                                    .frame(width: 164)
                                
                            case let expandButtonViewModel as ExpandButtonViewModel:
                                ExpandButtonView(viewModel: expandButtonViewModel)
                                
                            case let separatorViewModel as SeparatorViewModel:
                                SeparatorView(viewModel: separatorViewModel)
                                
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .frame(height: 104)
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

//MARK: - Expand Button View

extension MainSectionProductsView {
    
    class ExpandButtonViewModel: MainSectionProductsListItemViewModel, ObservableObject {
    
        @Published var title: String
        
        internal init(id: UUID = UUID(), title: String) {
            
            self.title = title
            super.init(id: id)
        }
    }
    
    struct ExpandButtonView: View {
        
        @ObservedObject var viewModel: ExpandButtonViewModel
        
        var body: some View {
            
            Button {
                
            } label: {
                
                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    Text(viewModel.title)
                        .font(.system(size: 14))
                    
                    Spacer()
                }
                .padding(12)
                .foregroundColor(.black)
                .background(Color.mainColorsGrayLightest
                                .cornerRadius(12))
                .frame(width: 48)
            }
        }
    }
}

//MARK: - Separator View

extension MainSectionProductsView {
    
    class SeparatorViewModel: MainSectionProductsListItemViewModel {}
    
    struct SeparatorView: View {
        
        let viewModel: SeparatorViewModel
        
        var body: some View {
            
            Capsule()
                .frame(width: 1, height: 60)
                .foregroundColor(.mainColorsGrayLightest)
        }
    }
    
}

//MARK: - Preview

struct MainSectionProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionProductsView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionProductsView.ViewModel {
    
    static let sample = MainSectionProductsView.ViewModel(productsTypeSelector: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета"), .init(id: "2", name: "Вклады")], selected: "0", style: .products), products: [ProductView.ViewModel.updating, MainSectionProductsView.ExpandButtonViewModel(title: "+5"), MainSectionProductsView.SeparatorViewModel(), ProductView.ViewModel.blocked], moreButton: .init(icon: .ic24MoreHorizontal, action: {}), isCollapsed: false)
    
}


