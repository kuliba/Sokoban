//
//  AnywayElement.Widget.swift
//
//
//  Created by Igor Malyarov on 08.06.2024.
//

import Foundation

extension AnywayElement {
    
    public enum Widget: Equatable {
        
        case otp(Int?)
        case product(Product)
    }
}

extension AnywayElement.Widget {
    
    public var id: ID {
        
        switch self {
        case .otp:  return .otp
        case .product: return .product
        }
    }
    
    public enum ID {
        
        case otp, product
    }
    
    public struct Product: Equatable {
        
        public let currency: Currency
        public let productID: ProductID
        public let productType: ProductType
        
        public init(
            currency: Currency,
            productID: ProductID,
            productType: ProductType
        ) {
            self.currency = currency
            self.productID = productID
            self.productType = productType
        }
        
        public typealias Currency = String
        public typealias ProductID = Int
        
        public enum ProductType: Equatable {
            
            case account, card
        }
    }
}
