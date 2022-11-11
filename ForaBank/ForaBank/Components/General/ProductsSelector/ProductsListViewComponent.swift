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
        
        @Published var products: [ProductView.ViewModel]
        @Published var typeSelector: OptionSelectorView.ViewModel?
        @Published var context: ProductSelectorView.ViewModel.Context
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(model: Model, products: [ProductView.ViewModel], typeSelector: OptionSelectorView.ViewModel?, context: ProductSelectorView.ViewModel.Context) {
            
            self.model = model
            self.products = products
            self.typeSelector = typeSelector
            self.context = context
        }
        
        convenience init?(model: Model, context: ProductSelectorView.ViewModel.Context) {
            
            guard let productsData = Self.reduce(model.products.value) else {
                return nil
            }
            
            let filterred = Self.filterred(products: productsData.products, context: context)
            let products = Self.reduce(model, checkProductId: context.checkProductId, products: filterred)
            let typeSelector = Self.makeTypeSelector(model, selected: productsData.productType.rawValue, context: context)
            
            self.init(model: model, products: products, typeSelector: typeSelector, context: context)
            
            bind()
            bindProducts()
        }
        
        private func bind() {
            
            if let typeSelector = typeSelector {
                
                typeSelector.$selected
                    .combineLatest($context)
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] data in
                        
                        let option = data.0
                        let context = data.1
                        
                        if let productType = ProductType(rawValue: option),
                           let products = model.products(productType) {
                            
                            let filterred = Self.filterred(products: products, context: context)
                            
                            self.products = Self.reduce(model, checkProductId: context.checkProductId, products: filterred)
                        }
                        
                        bindProducts()
                        
                    }.store(in: &bindings)
            }
            
            $context
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] context in
                    
                    // Exclude deposit
                    guard let productsData = Self.reduce(model.products.value) else {
                        return
                    }
                    
                    let options = Self.makeOptions(model, context: context)
                    
                    if let typeSelector = typeSelector {
                        
                        if typeSelector.selected == ProductType.deposit.rawValue {
                            typeSelector.update(options: options, selected: productsData.productType.rawValue)
                        } else {
                            typeSelector.update(options: options, selected: typeSelector.selected)
                        }
                    }
                    
                }.store(in: &bindings)
        }
        
        private func bindProducts() {
            
            for product in products {
                
                product.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ProductViewModelAction.ProductDidTapped:
                            self.action.send(ProductsListAction.Product.Tap(id: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
    }
}

extension ProductsListView.ViewModel {
    
    static func reduce(_ products: ProductsData) -> (productType: ProductType, products: [ProductData])? {
        
        let sortedTypes = ProductType.allCases.filter { $0 != .loan }.sorted { $0.order < $1.order }
        
        for productType in sortedTypes {
            if let products = products[productType], let product = products.first {
                return (product.productType, products)
            }
        }
        
        return nil
    }

    static func filterred(products: [ProductData], context: ProductSelectorView.ViewModel.Context) -> [ProductData] {
        
        let filterredProducts = products.filter { product in
            
            switch product.productType {
            case .card:
                
                guard let product = product as? ProductCardData else {
                    return false
                }
                
                if let loanBaseParam = product.loanBaseParam, product.isMain == false {
                    
                    return product.status == .active && product.statusPc == .active && loanBaseParam.clientId == product.ownerId
                    
                } else {
                    
                    return product.status == .active && product.statusPc == .active
                }

            case .account:
                
                guard let product = product as? ProductAccountData else {
                    return false
                }
                
                return product.status == .notBlocked
                
            case .deposit:
                
                return context.direction == .to

            default:
                return true
            }
        }
        
        switch context.direction {
        case .from: return filterredProducts.filter { $0.allowDebit == true }
        case .to: return filterredProducts.filter { $0.allowCredit == true }
        }
    }
  
    static func reduce(_ model: Model, checkProductId: ProductData.ID?, products: [ProductData]) -> [ProductView.ViewModel] {
        
        let sortedProducts = products.sorted { $0.productType.order < $1.productType.order }
        let products = sortedProducts.map { ProductView.ViewModel(with: $0, isChecked: $0.id == checkProductId, size: .small, style: .main, model: model) }
        
        return products
    }
    
    static func makeTypeSelector(_ model: Model, selected: Option.ID, context: ProductSelectorView.ViewModel.Context) -> OptionSelectorView.ViewModel {
        
        let options = Self.makeOptions(model, context: context)
        return .init(options: options, selected: selected, style: .productsSmall)
    }
    
    static func makeOptions(_ model: Model, context: ProductSelectorView.ViewModel.Context) -> [Option] {
        
        let isDirectionFrom = context.direction == .from
        
        let sortedTypes = model.productsTypes.filter {
            
            if isDirectionFrom == true {
                
               return $0 == .card || $0 == .account
                
            } else {
                
                return $0 != .loan
            }
            
        }.sorted { $0.order < $1.order }
        
        var options = sortedTypes.map { Option(id: $0.rawValue, name: $0.pluralName) }
        
        if 0...1 ~= options.count {
            options.removeAll()
        }
        
        return options
    }
}

// MARK: - View

struct ProductsListView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            if let typeSelector = viewModel.typeSelector {
                OptionSelectorView(viewModel: typeSelector)
            }
            
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

// MARK: - Action

enum ProductsListAction {
    
    enum Product {
        
        struct Tap: Action {
            
            let id: ProductData.ID
        }
    }
}

// MARK: - Previews

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProductsListView(viewModel: .init(
            model: .emptyMock,
            products: [.classicSmall, .accountSmall, .accountSmall],
            typeSelector: .init(
                options: [
                    .init(id: "CARD", name: ProductType.card.pluralName),
                    .init(id: "ACCOUNT", name: ProductType.account.pluralName)
                ],
                selected: "CARD", style: .productsSmall),
            context: .init(title: "Откуда", direction: .from)))
        .previewLayout(.sizeThatFits)
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}
