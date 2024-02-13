//
//  ProductsVisibilityPayload.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged

public extension Payload {
    
    struct ProductsVisibilityPayload {
        
        let category: Category
        let products: [Product]
        
        public init(category: Category, products: [Product]) {
            self.category = category
            self.products = products
        }
    }
}

public extension Payload.ProductsVisibilityPayload {
    
    enum Category {
        
        case card
        case account
        case deposit
        case loan
    }
}

public extension Payload.ProductsVisibilityPayload {
    
    struct Product {
        
        public typealias ProductID = Tagged<_ProductID, Int>
        public enum _ProductID {}

        public typealias Visibility = Tagged<_Visibility, Bool>
        public enum _Visibility {}
        
        let productID: ProductID
        let visibility: Visibility
        
        public init(productID: ProductID, visibility: Visibility) {
            self.productID = productID
            self.visibility = visibility
        }
    }
}
