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
        
        public let category: Category
        public let products: [Product]
        
        public init(category: Category, products: [Product]) {
            self.category = category
            self.products = products
        }
    }
}

public extension Payload.ProductsVisibilityPayload {
    
    enum Category: String, Encodable {
        
        case card = "CARD"
        case account = "ACCOUNT"
        case deposit = "DEPOSIT"
        case loan = "LOAN"
    }
}

public extension Payload.ProductsVisibilityPayload {
    
    struct Product: Encodable, Equatable {
        
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
