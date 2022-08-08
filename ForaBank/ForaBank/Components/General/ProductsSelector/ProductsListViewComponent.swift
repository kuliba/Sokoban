//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine

extension ProductsListView {
    
    // MARK: - ViewModel

    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var optionSelector: OptionSelectorView.ViewModel?
        @Published var products: [ProductView.ViewModel]
        @Published var productType: ProductType
        @Published var currency: Currency
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, currency: Currency, productType: ProductType, products: [ProductView.ViewModel]) {
            
            self.model = model
            self.currency = currency
            self.productType = productType
            self.products = products
            
            let products = model.products(currency: currency)
            optionSelector = Self.makeOptionSelector(products: products, selected: productType.rawValue)
            
            bind()
        }

        private func bind() {
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    if optionSelector == nil {
                        
                        let products = model.products(currency: currency)
                        optionSelector = Self.makeOptionSelector(products: products, selected: productType.rawValue)
                        
                    } else {
                        
                        guard let optionSelector = optionSelector else {
                            return
                        }
                        
                        let products = products.values.flatMap {$0}.filter { $0.currency == currency.description }
                        let options = Self.makeOptions(products: products)
                        
                        optionSelector.update(options: options, selected: optionSelector.selected)
                    }
                    
                }.store(in: &bindings)
            
            optionSelector?.$selected
                .combineLatest($currency)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let selected = data.0
                    let currency = data.1
                    
                    if let productType = ProductType(rawValue: selected) {
                        
                        products = Self.reduce(model, currency: currency, productType: productType) {
                            self.action.send(ProductSelectorView.ProductAction.Selected(productId: $0))
                        }
                        
                    } else {
                        
                        products = Self.reduce(model, currency: currency) {
                            self.action.send(ProductSelectorView.ProductAction.Selected(productId: $0))
                        }
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - Reduce

extension ProductsListView.ViewModel {
    
    static func makeOptionSelector(products: [ProductData], selected: Option.ID) -> OptionSelectorView.ViewModel? {
        
        let options = makeOptions(products: products)
        
        if 0...1 ~= options.count {
            return nil
        }
        
        return .init(options: options, selected: selected, style: .productsSmall)
    }
    
    static func makeOptions(products: [ProductData]) -> [Option] {
        
        let productTypes = products.reduce(into: [ProductType]()) { result, productData in
            
            if result.contains(where: { $0 == productData.productType }) == false  {
                result.append(productData.productType)
            }
        }
        
        let sortedProductTypes = productTypes.sorted { $0.order < $1.order }
        let options = sortedProductTypes.map { Option(id: $0.rawValue, name: $0.pluralName) }
        
        return options
    }
    
    static func reduce(_ model: Model, currency: Currency, productType: ProductType, action: @escaping (ProductData.ID) -> Void) -> [ProductView.ViewModel] {
        
        let filterredProducts = model.products(currency: currency, productType: productType)
        
        let products = filterredProducts.map { productData in
            ProductView.ViewModel(with: productData, size: .small, style: .main, model: model) {
                action(productData.id)
            }
        }
        
        return products
    }
    
    static func reduce(_ model: Model, currency: Currency, action: @escaping (ProductData.ID) -> Void) -> [ProductView.ViewModel] {
        
        let filterredProducts = model.products(currency: currency).sorted { $0.productType.order < $1.productType.order }
        
        let products = filterredProducts.map { productData in
            ProductView.ViewModel(with: productData, size: .small, style: .main, model: model) {
                action(productData.id)
            }
        }
        
        return products
    }
}

// MARK: - View

struct ProductsListView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            if let optionSelector = viewModel.optionSelector {
                
                OptionSelectorView(viewModel: optionSelector)
                    .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.products) { product in
                        ProductView(viewModel: product)
                            .frame(width: 112, height: 72)
                            .onTapGesture {
                                
                                viewModel.action.send(
                                    ProductsListAction.SelectedProduct(
                                        productId: product.id))
                            }
                    }
                }.padding(.horizontal, 20)
            }
        }
    }
}

enum ProductsListAction {
    
    struct SelectedProduct: Action {
        
        let productId: Int
    }
}

// MARK: - Preview Content

extension ProductsListView.ViewModel {
    
    static let sample = ProductsListView.ViewModel(.emptyMock, currency: .rub, productType: .card, products: [.classicSmall, .accountSmall, .accountSmall])
}

// MARK: - Previews

struct ProductsListViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
