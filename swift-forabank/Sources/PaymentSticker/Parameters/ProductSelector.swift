//
//  ProductSelector.swift
//  StickerPreview
//
//  Created by Igor Malyarov on 19.10.2023.
//
import Foundation

public extension Operation.Parameter {
    
    struct ProductSelector: Hashable {
        
        public let state: State
        public let selectedProduct: Product
        public let allProducts: [Product]
        
        public init(
            state: State,
            selectedProduct: Product,
            allProducts: [Product]
        ) {
            self.state = state
            self.selectedProduct = selectedProduct
            self.allProducts = allProducts
        }
        
        public struct Product: Hashable {
            
            let title: String
            let nameProduct: String
            let balance: String
            let description: String
            let cardImage: ImageData
            let paymentSystem: ImageData
            let backgroundImage: ImageData?
            let backgroundColor: String
            
            public init(
                title: String,
                nameProduct: String,
                balance: String,
                description: String,
                cardImage: ImageData,
                paymentSystem: ImageData,
                backgroundImage: ImageData?,
                backgroundColor: String
            ) {
                self.title = title
                self.nameProduct = nameProduct
                self.balance = balance
                self.description = description
                self.cardImage = cardImage
                self.paymentSystem = paymentSystem
                self.backgroundImage = backgroundImage
                self.backgroundColor = backgroundColor
            }
        }
        
        public enum State {
            
            case select
            case list
        }
    }
}

extension Operation.Parameter.ProductSelector {
    
    var parameterState: ProductStateViewModel.State {
        
        switch self.state {
        case .select:
            return .selected(.mapper(self.selectedProduct))
        case .list:
            return .list(
                .mapper(self.selectedProduct),
                self.allProducts.map({ ProductViewModel.mapper($0) })
            )
        }
    }
}
