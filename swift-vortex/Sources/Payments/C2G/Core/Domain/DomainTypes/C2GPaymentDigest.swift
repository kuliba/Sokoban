//
//  C2GPaymentDigest.swift
//  
//
//  Created by Igor Malyarov on 16.02.2025.
//

import ProductSelectComponent

public struct C2GPaymentDigest: Equatable {
    
    public let product: ProductSelect.Product
    public let uin: String
    
    public init(
        product: ProductSelect.Product,
        uin: String
    ) {
        self.product = product
        self.uin = uin
    }
    
    public struct ProductID: Equatable {
        
        public let id: Int
        public let type: ProductType
        
        public init(
            id: Int,
            type: ProductType
        ) {
            self.id = id
            self.type = type
        }
        
        public enum ProductType: Equatable {
            
            case account, card
        }
    }
}
