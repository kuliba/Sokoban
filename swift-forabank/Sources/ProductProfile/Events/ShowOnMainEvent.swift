//
//  ShowOnMainEvent.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Tagged

public enum ShowOnMainEvent: Equatable {
    
    case showOnMain(Product)
    case hideFromMain(Product)
}

public extension ShowOnMainEvent {
    
    struct Product: Equatable {
        
        public typealias ProductID = Tagged<_ProductID, Int>
        public enum _ProductID {}

        public typealias Visibility = Tagged<_Visibility, Bool>
        public enum _Visibility {}
        
        let productID: ProductID
        let visibility: Visibility
        
        public init(
            productID: ProductID,
            visibility: Visibility
        ) {
            self.productID = productID
            self.visibility = visibility
        }
    }
}
