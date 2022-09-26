//
//  ProductsListViewComponent.swift
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
        @Published var selector: OptionSelectorView.ViewModel?
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(model: Model, products: [ProductView.ViewModel], selector: OptionSelectorView.ViewModel?) {
            
            self.model = model
            self.products = products
            self.selector = selector
        }
        
        convenience init(model: Model, products: [ProductData], productType: ProductType) {
            
            let selector = Self.makeSelector(products: products, selected: productType.rawValue)
            let products = Self.reduce(model: model, products: products)
            
            self.init(model: model, products: products, selector: selector)
        }
    }
}

extension ProductsListView.ViewModel {
    
    static func makeSelector(products: [ProductData], selected: Option.ID) -> OptionSelectorView.ViewModel? {
        
        let options = reduce(products: products)
        
        if 0...1 ~= options.count {
            return nil
        }
        
        return .init(options: options, selected: selected, style: .productsSmall)
    }
    
    static func reduce(products: [ProductData]) -> [Option] {
        
        let productTypes = products.reduce(into: [ProductType]()) { result, productData in
            
            if result.contains(where: { $0 == productData.productType }) == false  {
                result.append(productData.productType)
            }
        }
        
        let sortedProductTypes = productTypes.sorted { $0.order < $1.order }
        let options = sortedProductTypes.map { Option(id: $0.rawValue, name: $0.pluralName) }
        
        return options
    }
    
    static func reduce(model: Model, products: [ProductData]) -> [ProductView.ViewModel] {
        
        let sortedProducts = products.sorted { $0.productType.order < $1.productType.order }
        let products = sortedProducts.map { ProductView.ViewModel(with: $0, size: .small, style: .main, model: model) }
        
        return products
    }
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
            selector: nil))
        .previewLayout(.sizeThatFits)
        .padding(.vertical, 8)
    }
}
