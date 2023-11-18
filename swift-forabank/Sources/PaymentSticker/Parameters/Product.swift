//
//  Product.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//

public extension Operation.Parameter {
    
    struct Product: Hashable {
        
        public let state: State
        public let selectedProduct: Option
        public let allProducts: [Option]
        
        public init(
            state: Operation.Parameter.Product.State,
            selectedProduct: Operation.Parameter.Product.Option,
            allProducts: [Operation.Parameter.Product.Option]
        ) {
            self.state = state
            self.selectedProduct = selectedProduct
            self.allProducts = allProducts
        }
        
        public struct Option: Hashable {
            
            let paymentSystem: String
            let background: String
            let title: String
            let nameProduct: String
            let balance: String
            let description: String
            
            public init(
                paymentSystem: String,
                background: String,
                title: String,
                nameProduct: String,
                balance: String,
                description: String
            ) {
                self.paymentSystem = paymentSystem
                self.background = background
                self.title = title
                self.nameProduct = nameProduct
                self.balance = balance
                self.description = description
            }
        }
        
        public enum State {
            
            case select
            case list
        }
    }
}

extension Operation.Parameter.Product {
    
    var parameterState: ProductStateViewModel.State {
        
        switch self.state {
        case .select:
            return .selected(.mapper(self.selectedProduct))
        case .list:
            return .list(
                .mapper(
                    self.selectedProduct),
                    self.allProducts.map({ ProductViewModel.mapper($0) })
            )
        }
    }
}
