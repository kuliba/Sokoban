//
//  Product.swift
//  
//
//  Created by Andryusina Nataly on 14.02.2024.
//

import Tagged

public struct Product: Equatable, Hashable {
    
    public typealias ProductID = Tagged<_ProductID, Int>
    public enum _ProductID {}

    public typealias Visibility = Tagged<_Visibility, Bool>
    public enum _Visibility {}
    
    public let productID: ProductID
    public let visibility: Visibility
    
    public init(
        productID: ProductID,
        visibility: Visibility
    ) {
        self.productID = productID
        self.visibility = visibility
    }
}
