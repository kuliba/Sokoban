//
//  ProductsListView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 25.09.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductsListView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var selector: OptionSelectorView.ViewModel
        @Published var products: [ProductView.ViewModel]
        
        var selectedType: ProductType? {
            
            guard let selectedType = ProductType(rawValue: selector.selected) else {
                return nil
            }
            
            return selectedType
        }
        
        private let selectedProductId: ProductData.ID?
        private let filter: ProductData.Filter
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(products: [ProductView.ViewModel], selector: OptionSelectorView.ViewModel, selectedProductId: ProductData.ID?, filter: ProductData.Filter, model: Model) {
            
            self.model = model
            self.products = products
            self.selector = selector
            self.selectedProductId = selectedProductId
            self.filter = filter
        }
        
        convenience init?(selectedProductId: ProductData.ID?, filter: ProductData.Filter, model: Model) {
            
            let availableProductTypes = filter.filterredProductsTypes(model.allProducts)
            guard availableProductTypes.isEmpty == false else {
                return nil
            }
   
            let selectedType = availableProductTypes[0]
            let selector = Self.makeSelector(productTypes: availableProductTypes, selected: selectedType)
            
            self.init(products: [], selector: selector, selectedProductId: selectedProductId, filter: filter, model: model)
            
            bind()
        }

        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    let availableProductTypes = filter.filterredProductsTypes(model.allProducts)
                    if availableProductTypes.isEmpty == false {
                        
                        if let selectedType = selectedType, availableProductTypes.contains(selectedType) {
                            
                            selector = Self.makeSelector(productTypes: availableProductTypes, selected: selectedType)
                        } else {
                            
                            let selectedType = availableProductTypes[0]
                            selector = Self.makeSelector(productTypes: availableProductTypes, selected: selectedType)
                        }
                        
                        bind(selector: selector)
                        
                    } else {
                        
                        action.send(ProductsListViewModelAction.CloseList())
                    }
                    
                }.store(in: &bindings)
            
        }
        
        private func bind(selector: OptionSelectorView.ViewModel) {
            
            selector.$selected
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] selectedOption in
                    
                    guard let selectedType = ProductType(rawValue: selectedOption) else {
                        return
                    }
                    
                    products = Self.reduce(products: model.allProducts, selectedProductType: selectedType, filter: filter, selectedProductId: selectedProductId, model: model)
                    bind(products: products)
                    
                }.store(in: &bindings)
        }
        
        private func bind(products: [ProductView.ViewModel]) {
            
            for product in products {
                
                product.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ProductViewModelAction.ProductDidTapped:
                            self.action.send(ProductsListViewModelAction.Product.Tap(id: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
    }
}

//MARK: - Reducers

extension ProductsListView.ViewModel {
    
    static func makeSelector(productTypes: [ProductType], selected: ProductType) -> OptionSelectorView.ViewModel {
        
        if productTypes.count > 1 {
            
            let options = productTypes.map { Option(id: $0.rawValue, name: $0.pluralName) }
       
            return .init(options: options, selected: selected.rawValue, style: .productsSmall)
            
        } else {

            return .init(options: [], selected: selected.rawValue, style: .productsSmall)
        }
    }
    
    static func reduce(products: [ProductData], selectedProductType: ProductType, filter: ProductData.Filter, selectedProductId: ProductData.ID?, model: Model) -> [ProductView.ViewModel] {
        
        let availableProducts = filter.filterredProducts(products)
        let productsForType = availableProducts.filter({ $0.productType == selectedProductType })
        let sortedProducts = productsForType.sorted { $0.productType.order < $1.productType.order }
        let productsViewModels = sortedProducts.map { ProductView.ViewModel(with: $0, isChecked: $0.id == selectedProductId, size: .small, style: .main, model: model) }
        
        return productsViewModels
    }
}

// MARK: - Action

enum ProductsListViewModelAction {
    
    enum Product {
        
        struct Tap: Action {
            
            let id: ProductData.ID
        }
    }
    
    struct CloseList: Action {}
}

// MARK: - View

struct ProductsListView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            OptionSelectorView(viewModel: viewModel.selector)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.products) { product in
                        
                        ZStack {
    
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 62, height: 64)
                                .foregroundColor(.mainColorsBlack)
                                .opacity(0.15)
                                .offset(x: 0, y: 13)
                                .blur(radius: 8)
                            
                            ProductView(viewModel: product)
                                .frame(width: 112, height: 72)
                        }
                        .frame(height: 72)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProductsListView(viewModel: .init(
            products: [.classicSmall, .accountSmall, .accountSmall],
            selector: .init(
                options: [
                    .init(id: "CARD", name: ProductType.card.pluralName),
                    .init(id: "ACCOUNT", name: ProductType.account.pluralName)
                ],
                selected: "CARD", style: .productsSmall),
            selectedProductId: 10,
            filter: .generalFrom, model: .emptyMock))
        .previewLayout(.sizeThatFits)
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}
