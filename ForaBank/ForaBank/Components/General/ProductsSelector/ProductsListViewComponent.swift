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
        @Published var context: ProductSelectorView.ViewModel.Context
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, productType: ProductType, products: [ProductView.ViewModel], context: ProductSelectorView.ViewModel.Context) {
            
            self.model = model
            self.productType = productType
            self.products = products
            self.context = context
            
            let products = model.products(currency: context.currency)
            optionSelector = Self.makeOptionSelector(products: products, selected: productType.rawValue)
            
            bind()
            bindOption(productsData: model.products.value, currency: context.currency)
        }
        
        func bind() {
            
            for product in products {
                
                product.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ProductViewModelAction.ProductDidTapped:
                            self.action.send(ProductSelectorView.ProductAction.Selected(productId: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func bindOption(productsData: ProductsData, currency: Currency) {
            
            let products = model.products(currency: currency, currencyOperation: .buy, products: productsData)
            
            if optionSelector == nil {
                
                optionSelector = Self.makeOptionSelector(products: products, selected: productType.rawValue)
                
                if let optionSelector = optionSelector {
                    
                    optionSelector.$selected
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] selected in
                            
                            if let productType = ProductType(rawValue: selected) {
                                
                                self.products = Self.reduce(model, currency: currency, currencyOperation: .buy, productType: productType, context: context)
                                
                                if products.isEmpty == true {
                                    
                                    if let option = optionSelector.options.first {
                                        optionSelector.selected = option.id
                                    }
                                }
                                
                            } else {
                                
                                self.products = Self.reduce(model, currency: currency, currencyOperation: .buy)
                            }
                            
                        }.store(in: &bindings)
                }
                
            } else {
                
                guard let optionSelector = optionSelector else {
                    return
                }
                
                let options = Self.makeOptions(products: products)
                optionSelector.update(options: options, selected: optionSelector.selected)
            }
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
    
    static func reduce(_ model: Model, currency: Currency, currencyOperation: CurrencyOperation, productType: ProductType, context: ProductSelectorView.ViewModel.Context) -> [ProductView.ViewModel] {

        var filterredProducts = model.products(currency: currency, currencyOperation: currencyOperation, productType: productType).sorted { $0.productType.order < $1.productType.order }

        if !context.isAdditionalProducts {
            
            filterredProducts = filterredProducts.filter({ $0.ownerProduct }).uniqueValues(value: { $0.additionalAccountId })
        }
        
        let products = filterredProducts.map { ProductView.ViewModel(with: $0, size: .small, style: .main, model: model) }

        return products
    }

    static func reduce(_ model: Model, currency: Currency, currencyOperation: CurrencyOperation) -> [ProductView.ViewModel] {

        let filterredProducts = model.products(currency: currency, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }

        let products = filterredProducts.map { ProductView.ViewModel(with: $0, size: .small, style: .main, model: model) }

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
    
    static let sample = ProductsListView.ViewModel(.emptyMock, productType: .card, products: [.classicSmall, .accountSmall, .accountSmall], context: .init(isAdditionalProducts: false))
}

// MARK: - Previews

struct ProductsListViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
