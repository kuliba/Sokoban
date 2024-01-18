//
//  Product.swift
//
//
//  Created by Igor Malyarov on 16.01.2024.
//

import Tagged

public struct Product: Equatable, Identifiable {
    
    public let id: ProductID
    public let productType: ProductType
    
    public init(id: ProductID, productType: ProductType) {
        
        self.id = id
        self.productType = productType
    }
}

public extension Product {
    
    typealias ProductID = Tagged<_ProductID, Int>
    enum _ProductID {}
    
    enum ProductType {
        
        case account, card
    }
}
