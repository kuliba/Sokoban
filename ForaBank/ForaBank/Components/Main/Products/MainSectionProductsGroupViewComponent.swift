//
//  MainSectionProductsGroupViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.05.2022.
//

import Foundation
import SwiftUI
import Combine
import ScrollViewProxy

//MARK: - ViewModel

extension MainSectionProductsGroupView {
    
    class ViewModel: Identifiable, ObservableObject {
        
        var id: String { productType.rawValue }
        let productType: ProductType
        @Published var presented: [ProductView.ViewModel]
        @Published var newProductViewModel: ButtonNewProduct.ViewModel?
        @Published var collapsaleProductsTitle: String?
        @Published var isCollapsed: Bool
        @Published var isSeparator: Bool
        let dimensions: Dimensions = .initial
        
        private var products: CurrentValueSubject<[ProductView.ViewModel], Never> = .init([])
        private let settings: MainProductsGroupSettings
        private var bindings = Set<AnyCancellable>()
        
        init(productType: ProductType, presented: [ProductView.ViewModel], newProductViewModel: ButtonNewProduct.ViewModel?, collapsaleProductsTitle: String?, isCollapsed: Bool, isSeparator: Bool, settings: MainProductsGroupSettings = .base) {
            
            self.productType = productType
            self.presented = presented
            self.newProductViewModel = newProductViewModel
            self.collapsaleProductsTitle = collapsaleProductsTitle
            self.isCollapsed = isCollapsed
            self.isSeparator = isSeparator
            self.products.value = presented
            self.settings = settings
        }
        
        init(productType: ProductType, products: [ProductView.ViewModel], settings: MainProductsGroupSettings = .base) {
            
            self.productType = productType
            self.products.value = products
            self.settings = settings
            self.presented = []
            self.newProductViewModel = nil
            self.isCollapsed = true
            self.isSeparator = true
            
            bind()
        }
        
        func update(with products: [ProductView.ViewModel]) {
            
            self.products.value = products
        }
        
        var width: CGFloat {
            
            var result: CGFloat = 0
            
            // products width
            result += CGFloat(presented.count) * dimensions.widths.product
            result += CGFloat(max(presented.count - 1, 0)) * dimensions.spacing
            
            // new product width
            if newProductViewModel != nil {
                
                result += dimensions.spacing
                result += dimensions.widths.new
            }
            
            // group button width
            if collapsaleProductsTitle != nil {
                
                result += dimensions.spacing
                result += dimensions.widths.button
            }
            
            // separator width
            if isSeparator == true {
                
                result += dimensions.spacing
                result += dimensions.widths.separator
            }
            
            return result
        }
        
        private func bind() {
            
           products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    withAnimation {
                        
                        let result = reduce(products: products, isCollapsed: isCollapsed, settings: settings)
                        presented = result.products
                        collapsaleProductsTitle = result.collapsaleProductsTitle
                        
                        if productType == .card, presented.count <= settings.maxCardsAmountRequeredNewProduct {
                            
                            //TODO: real action required
                            newProductViewModel = ButtonNewProduct.ViewModel(icon: .ic24NewCardColor, title: "Хочу карту", subTitle: "Бесплатно", action: {})
                        }
                    }

                }.store(in: &bindings)
            
            $isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        let result = reduce(products: products.value, isCollapsed: isCollapsed, settings: settings)
                        presented = result.products
                        collapsaleProductsTitle = result.collapsaleProductsTitle
                    }

                }.store(in: &bindings)
        }
        
        func reduce(products: [ProductView.ViewModel], isCollapsed: Bool, settings: MainProductsGroupSettings) -> (products: [ProductView.ViewModel], collapsaleProductsTitle: String?) {
            
            if products.count <= settings.minVisibleProductsAmount {
                
                return (products, nil)
                
            } else {
                
                if isCollapsed == true {
                    
                    let visibleProducts = Array(products.prefix(settings.minVisibleProductsAmount))
                    let remainProductsAmount = products.count - settings.minVisibleProductsAmount

                    return (visibleProducts, "+\(remainProductsAmount)")
                    
                } else {
     
                    return (products, "")
                }
            }
        }
    }
}

//MARK: - ViewModel Types

extension MainSectionProductsGroupView.ViewModel {
    
    struct Dimensions {
        
        let spacing: CGFloat
        let widths: Widths
        
        struct Widths {
            
            let product: CGFloat
            let new: CGFloat
            let button: CGFloat
            let separator: CGFloat
        }
        
        static let initial = Dimensions(spacing: 8, widths: .init(product: 164, new: 112, button: 48, separator: 1))
    }
}

//MARK: - View

struct MainSectionProductsGroupView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: viewModel.dimensions.spacing) {
            
            ForEach(viewModel.presented) { productViewModel in
                
                ProductView(viewModel: productViewModel)
                    .frame(width: viewModel.dimensions.widths.product)
                    .scrollId(productViewModel.id)
            }
            
            if let newProductViewModel = viewModel.newProductViewModel {
                
                ButtonNewProduct(viewModel: newProductViewModel)
                    .frame(width: viewModel.dimensions.widths.new)
            }
            
            if let collapsaleProductsTitle = viewModel.collapsaleProductsTitle {
                
                GroupButtonView(title: collapsaleProductsTitle, isCollapsed: $viewModel.isCollapsed)
                    .frame(width: viewModel.dimensions.widths.button)
            }
            
            if viewModel.isSeparator == true {
                
                Capsule(style: .continuous)
                    .frame(width: viewModel.dimensions.widths.separator)
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
                
                if isCollapsed == true {
                    
                    Text(title)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                } else {
                    
                    Image.ic24ChevronsLeft
                        .foregroundColor(.iconBlack)
                }
            }
            .onTapGesture { isCollapsed.toggle() }
        }
    }
}

//MARK: - Preview

struct MainSectionProductsGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionProductsGroupView(viewModel: .sampleProductsOne)
                .previewLayout(.fixed(width: 375, height: 200))
            
            ScrollView(.horizontal) {
                
                MainSectionProductsGroupView(viewModel: .sampleProducts)
            }
                .previewLayout(.fixed(width: 400, height: 200))
            
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
    
    static let sampleWant = MainSectionProductsGroupView.ViewModel(productType: .card, presented: [.classic], newProductViewModel: .sampleWantCard, collapsaleProductsTitle: nil, isCollapsed: false, isSeparator: false)
    
    static let sampleGroup = MainSectionProductsGroupView.ViewModel(productType: .card, presented: [.classic], newProductViewModel: nil, collapsaleProductsTitle: "+5", isCollapsed: false, isSeparator: true)
    
    static let sampleGroupCollapsed = MainSectionProductsGroupView.ViewModel(productType: .card, presented: [.classic], newProductViewModel: nil, collapsaleProductsTitle: "+5", isCollapsed: true, isSeparator: true)
    
    static let sampleProducts = MainSectionProductsGroupView.ViewModel(productType: .card, products: [.classic, .account, .blocked])
    
    static let sampleProductsOne = MainSectionProductsGroupView.ViewModel(productType: .card, products: [.classic])
}

extension ButtonNewProduct.ViewModel {
    
    static let sampleWantCard = ButtonNewProduct.ViewModel(icon: .ic24NewCardColor, title: "Хочу карту", subTitle: "Бесплатно", action: {})
}
