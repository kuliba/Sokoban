//
//  AnywayElement.Widget.swift
//
//
//  Created by Igor Malyarov on 08.06.2024.
//

import Foundation

extension AnywayElement {
    
    public enum Widget: Equatable {
        
        case info(Info)
        case otp(Int?, String?)
        case product(Product)
    }
}

extension AnywayElement.Widget {
    
    public var id: ID {
        
        switch self {
        case .info:     return .info
        case .otp:     return .otp
        case .product: return .product
        }
    }
    
    public enum ID {
        
        case info, otp, product
    }
    
    public struct Info: Equatable {
        
        public let currency: Currency?
        public let fields: [Field]
        
        public init(
            currency: Currency?,
            fields: [Field]
        ) {
            self.currency = currency
            self.fields = fields
        }
        
        public typealias Currency = String
        
        public enum Field: Equatable {
            
            case amount(Decimal)
            case fee(Decimal)
            case total(Decimal)
        }
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
