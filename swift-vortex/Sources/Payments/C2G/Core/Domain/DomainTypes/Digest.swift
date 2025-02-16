//
//  Digest.swift
//  
//
//  Created by Igor Malyarov on 16.02.2025.
//

public struct Digest: Equatable {
    
    public let productID: ProductID
    public let uin: String
    
    public init(
        productID: ProductID,
        uin: String
    ) {
        self.productID = productID
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
