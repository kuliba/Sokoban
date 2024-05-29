//
//  ProductsListViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 11.07.2022.
//

import SwiftUI
import Combine

extension CurrencyWalletListView {
    
    // MARK: - ViewModel
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var optionSelector: OptionSelectorView.ViewModel?
        @Published var products: [ProductViewModel]
        @Published var productType: ProductType
        @Published var currencyOperation: CurrencyOperation
        @Published var currency: Currency
        
        var filter: ProductData.Filter {
            
            switch currencyOperation {
            case .buy:
                return .currencyWalletTo
                
            case .sell:
                return .currencyWalletFrom
            }
        }
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, currencyOperation: CurrencyOperation, currency: Currency, productType: ProductType, products: [ProductViewModel]) {
            
            self.model = model
            self.currencyOperation = currencyOperation
            self.currency = currency
            self.productType = productType
            self.products = products
            
            let products = model.products(currency: currency, currencyOperation: currencyOperation)
            optionSelector = Self.makeOptionSelector(products: products, selected: productType.rawValue)
            
            bind()
            bindOption(productsData: model.products.value, currencyOperation: currencyOperation)
        }
        
        private func bind() {
            
            model.products
                .combineLatest($currencyOperation)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let productsData = data.0
                    let currencyOperation = data.1
                    
                    bindOption(productsData: productsData, currencyOperation: currencyOperation)
                    
                }.store(in: &bindings)
            
            if let optionSelector = optionSelector {
                
                optionSelector.$selected
                    .combineLatest($currency)
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] data in
                        
                        let selected = data.0
                        let currency = data.1
                        
                        if let productType = ProductType(rawValue: selected) {
                            
                            products = Self.reduce(model, currency: currency, currencyOperation: currencyOperation, productType: productType, filter: filter, selectedProductId: selected.id)
                            bind(products)
                            
                            if products.isEmpty == true {
                                
                                if let option = optionSelector.options.first {
                                    optionSelector.selected = option.id
                                }
                            }
                            
                        } else {
                            
                            products = Self.reduce(model, currency: currency, currencyOperation: currencyOperation, selectedProductId: selected.id)
                            bind(products)
                        }
                        
                    }.store(in: &bindings)
                
            } else {
                
                $currency
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] currency in
                        
                        products = Self.reduce(model, currency: currency, currencyOperation: currencyOperation, selectedProductId: -1)
                        bind(products)
                        
                    }.store(in: &bindings)
            }
        }
        
        func bind(_ products: [ProductViewModel]) {
            
            for product in products {
                
                product.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ProductViewModelAction.ProductDidTapped:
                            self.action.send(CurrencyWalletSelectorView.ProductAction.Selected(productId: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        private func bindOption(productsData: ProductsData, currencyOperation: CurrencyOperation) {
            
            let products = model.products(currency: currency, currencyOperation: currencyOperation, products: productsData)
            
            if optionSelector == nil {
                
                optionSelector = Self.makeOptionSelector(products: products, selected: productType.rawValue)
                
                if let optionSelector = optionSelector {
                    
                    optionSelector.$selected
                        .combineLatest($currency)
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] data in
                            
                            let selected = data.0
                            let currency = data.1
                            
                            if let productType = ProductType(rawValue: selected) {
                                
                                self.products = Self.reduce(model, currency: currency, currencyOperation: currencyOperation, productType: productType, filter: filter, selectedProductId: selected.id)
                                bind(self.products)
                                
                                if products.isEmpty == true {
                                    
                                    if let option = optionSelector.options.first {
                                        optionSelector.selected = option.id
                                    }
                                }
                                
                            } else {
                                
                                self.products = Self.reduce(model, currency: currency, currencyOperation: currencyOperation, selectedProductId: -1)
                                bind(self.products)
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

extension CurrencyWalletListViewModel {
    
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
    
    static func reduce(_ model: Model, currency: Currency, currencyOperation: CurrencyOperation, productType: ProductType, filter: ProductData.Filter, selectedProductId: Int) -> [ProductViewModel] {

        let sortedProducts = model.products(currency: currency, currencyOperation: currencyOperation, productType: productType).sorted { $0.productType.order < $1.productType.order }
        let filteredProducts = filter.filteredProducts(sortedProducts)
        
        let products = filteredProducts.map {
         
            ProductViewModel(
                with: $0, 
                isChecked: ($0.id == selectedProductId),
                size: .small,
                style: .main,
                model: model,
                cardAction: nil,
                cvvInfo: nil
            )
        }

        return products
    }

    static func reduce(_ model: Model, currency: Currency, currencyOperation: CurrencyOperation, selectedProductId: Int) -> [ProductViewModel] {

        let filteredProducts = model.products(currency: currency, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }

        let products = filteredProducts.map { ProductViewModel(with: $0, isChecked: ($0.id == selectedProductId), size: .small, style: .main, model: model) }

        return products
    }
}

// MARK: - View

struct CurrencyWalletListView: View {
    
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
                                    CurrencyWalletListAction.SelectedProduct(
                                        productId: product.id))
                            }
                    }
                }.padding(.horizontal, 20)
            }
        }
    }
}

enum CurrencyWalletListAction {
    
    struct SelectedProduct: Action {
        
        let productId: Int
    }
}

// MARK: - Preview Content

extension CurrencyWalletListViewModel {
    
    static let sample = CurrencyWalletListViewModel(.emptyMock, currencyOperation: .buy, currency: .rub, productType: .card, products: [.classicSmall, .accountSmall, .accountSmall])
}

// MARK: - Previews

struct CurrencyWalletListViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyWalletListView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
