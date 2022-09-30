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
        @Published var options: OptionSelectorView.ViewModel?
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(model: Model, products: [ProductView.ViewModel], options: OptionSelectorView.ViewModel?) {
            
            self.model = model
            self.products = products
            self.options = options
        }
        
        convenience init?(model: Model, context: ProductSelectorView.ViewModel.Context) {
            
            guard let productsData = Self.reduce(model.products.value) else {
                return nil
            }
            
            let filterred = Self.filterred(products: productsData.products, context: context)
            let products = Self.reduce(model: model, products: filterred)
            let options = Self.makeOptions(selected: productsData.productType.rawValue)
            
            self.init(model: model, products: products, options: options)
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
                return true
                
            default:
                return false
            }
        }
        
        switch context.direction {
        case .from: return filterredProducts.filter { $0.allowDebit == true }
        case .to: return filterredProducts.filter { $0.allowCredit == true }
        }
    }
  
    static func reduce(model: Model, products: [ProductData]) -> [ProductView.ViewModel] {
        
        let sortedProducts = products.sorted { $0.productType.order < $1.productType.order }
        let products = sortedProducts.map { ProductView.ViewModel(with: $0, size: .small, style: .main, model: model) }
        
        return products
    }
    
    static func makeOptions(selected: Option.ID) -> OptionSelectorView.ViewModel? {
        
        let sortedTypes = ProductType.allCases.filter { $0 != .loan }.sorted { $0.order < $1.order }
        let options = sortedTypes.map { Option(id: $0.rawValue, name: $0.pluralName) }
        
        if 0...1 ~= options.count {
            return nil
        }
        
        return .init(options: options, selected: selected, style: .productsSmall)
    }
    
    func update(context: ProductSelectorView.ViewModel.Context) {}
}

// MARK: - View

struct ProductsListView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.products) { product in
                    ProductView(viewModel: product)
                        .frame(width: 112, height: 72)
                        .onTapGesture {
                            
                            viewModel.action.send(ProductsListAction.SelectedProduct(id: product.id))
                        }
                }
            }.padding(.horizontal, 20)
        }
    }
}

// MARK: - Action

enum ProductsListAction {
    
    struct SelectedProduct: Action {
        
        let id: ProductData.ID
    }
}

// MARK: - Previews

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProductsListView(viewModel: .init(
            model: .emptyMock,
            products: [.classicSmall, .accountSmall, .accountSmall],
            options: nil))
        .previewLayout(.sizeThatFits)
        .padding(.vertical, 8)
    }
}
