//
//  PaymentsProductSelectorViewComponet.swift
//  ForaBank
//
//  Created by Max Gribov on 15.03.2022.
//

import SwiftUI
import Combine

//MARK: - View Model

extension PaymentsProductSelectorView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var categories: OptionSelectorView.ViewModel?
        @Published var productsFilterred: [ProductViewModel]
        
        @Published internal var products: [ProductViewModel]
        
        private var bindings = Set<AnyCancellable>()
        
        init(categories: OptionSelectorView.ViewModel?, products: [ProductViewModel]) {
            
            self.categories = categories
            self.productsFilterred = []
            self.products = products
        }
        
        init(_ model: Model) {
            
            self.categories = nil
            self.productsFilterred = []
            self.products = []

            bind()
            bindCategories()
        }
        
        internal func bind() {
            
            $products
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] productsAll in
                    
                    if let categories = categories, let productType = ProductType(rawValue: categories.selected) {
                        
                        self.productsFilterred = filteredProducts(prpductType: productType, products: productsAll)
                        
                    } else {
                        
                        self.productsFilterred = productsAll
                    }
                    
                }.store(in: &bindings)
        }
        
        internal func bind(_ products: [ProductViewModel]) {
            
            for product in products {
                
                product.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ProductViewModelAction.ProductDidTapped:
                            self.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: product.id))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
        
        func bindCategories() {
            
            categories?.$selected
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] selected in
                    
                    if let productType = ProductType(rawValue: selected) {
                        
                        self.productsFilterred = filteredProducts(prpductType: productType, products: products)
                        
                    } else {
                        
                        self.productsFilterred = products
                    }
                    
                }.store(in: &bindings)
        }
        
        func filteredProducts(prpductType: ProductType, products: [ProductViewModel]) -> [ProductViewModel] {
            
            products.filter{ $0.productType == prpductType }
        }
    }
    
    enum ViewModelAction {
        
        struct SelectedProduct: Action {
            
            let productId: Int
        }
    }
}

//MARK: - View

struct PaymentsProductSelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            if let categoriesViewModel = viewModel.categories {
                
                OptionSelectorView(viewModel: categoriesViewModel)
                    .frame(height: 24)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.productsFilterred) { productViewModel in
                        
                        ProductView(viewModel: productViewModel)
                            .frame(width: 112, height: 72)
                            .onTapGesture {
                                
                                viewModel.action.send(PaymentsProductSelectorView.ViewModelAction.SelectedProduct(productId: productViewModel.id))
                            }
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct PaymentsProductSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsProductSelectorView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

extension PaymentsProductSelectorView.ViewModel {
    
    
    static let sample = PaymentsProductSelectorView.ViewModel(categories: .init(options: [.init(id: "0", name: "Карты"), .init(id: "1", name: "Счета"), .init(id: "2", name: "Вклады")], selected: "0", style: .productsSmall), products: [.classicSmall, .accountSmall])
}
