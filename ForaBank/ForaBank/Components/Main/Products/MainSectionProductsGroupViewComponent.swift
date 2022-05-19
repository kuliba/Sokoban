//
//  MainSectionProductsGroupViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.05.2022.
//

import Foundation
import SwiftUI

extension MainSectionProductsGroupView {
    
    class ViewModel: Identifiable, ObservableObject {
        
        var id: String { productType.rawValue }
        let productType: ProductType
        @Published var presented: [ProductView.ViewModel]
        @Published var newProductViewModel: ButtonNewProduct.ViewModel?
        @Published var collapsaleProductsTitle: String?
        @Published var isCollapsed: Bool
        @Published var isSeparator: Bool
        
        private var products: [ProductView.ViewModel]
        
        init(productType: ProductType, presented: [ProductView.ViewModel], newProductViewModel: ButtonNewProduct.ViewModel?, collapsaleProductsTitle: String?, isCollapsed: Bool, isSeparator: Bool, products: [ProductView.ViewModel]) {
            
            self.productType = productType
            self.presented = products
            self.newProductViewModel = newProductViewModel
            self.collapsaleProductsTitle = collapsaleProductsTitle
            self.isCollapsed = isCollapsed
            self.isSeparator = isSeparator
            self.products = products
        }
    }
}

struct MainSectionProductsGroupView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 8) {
            
            ForEach(viewModel.presented) { productViewModel in
                
                ProductView(viewModel: productViewModel)
                    .frame(width: 164)
            }
            
            if let newProductViewModel = viewModel.newProductViewModel {
                
                ButtonNewProduct(viewModel: newProductViewModel)
                    .frame(width: 112)
            }
            
            if let collapsaleProductsTitle = viewModel.collapsaleProductsTitle {
                
                GroupButtonView(title: collapsaleProductsTitle, isCollapsed: $viewModel.isCollapsed)
            }
            
            if viewModel.isSeparator == true {
                
                Capsule(style: .continuous)
                    .frame(width: 1)
                    .foregroundColor(.mainColorsGrayLightest)
                    .padding(.vertical, 20)
            }
        }
        .frame(height: 104)
    }
}

extension MainSectionProductsGroupView {
    
    struct GroupButtonView: View {
        
        let title: String
        @Binding var isCollapsed: Bool
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                if isCollapsed == false {
                    
                    Text(title)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                } else {
                    
                    Image.ic24ChevronsLeft
                        .foregroundColor(.iconBlack)
                }
            }
            .frame(width: 48)
            .onTapGesture { isCollapsed.toggle() }
        }
    }
}

//MARK: - Preview

struct MainSectionProductsGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionProductsGroupView(viewModel: .sampleWant)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView(viewModel: .sampleGroup)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView(viewModel: .sampleGroupCollapsed)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView.GroupButtonView(title: "+5", isCollapsed: .constant(false))
                .previewLayout(.fixed(width: 200, height: 100))
            
            MainSectionProductsGroupView.GroupButtonView(title: "+5", isCollapsed: .constant(true))
                .previewLayout(.fixed(width: 200, height: 100))
        }
    }
}

//MARK: - Preview Content

extension MainSectionProductsGroupView.ViewModel {
    
    static let sampleWant = MainSectionProductsGroupView.ViewModel(productType: .card, presented: [.classic], newProductViewModel: .sampleWantCard, collapsaleProductsTitle: nil, isCollapsed: false, isSeparator: false, products: [.classic])
    
    static let sampleGroup = MainSectionProductsGroupView.ViewModel(productType: .card, presented: [.classic], newProductViewModel: nil, collapsaleProductsTitle: "+5", isCollapsed: false, isSeparator: true, products: [.classic])
    
    static let sampleGroupCollapsed = MainSectionProductsGroupView.ViewModel(productType: .card, presented: [.classic], newProductViewModel: nil, collapsaleProductsTitle: "+5", isCollapsed: true, isSeparator: true, products: [.classic])
}

extension ButtonNewProduct.ViewModel {
    
    static let sampleWantCard = ButtonNewProduct.ViewModel(icon: .ic24NewCardColor, title: "Хочу карту", subTitle: "Бесплатно", action: {})
}
