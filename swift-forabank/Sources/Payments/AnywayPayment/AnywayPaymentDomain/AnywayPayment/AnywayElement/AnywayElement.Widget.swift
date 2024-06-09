//
//  AnywayElement.Widget.swift
//
//
//  Created by Igor Malyarov on 08.06.2024.
//

import Foundation

extension AnywayElement {
    
    public enum Widget: Equatable {
        
        case core(PaymentCore)
        case otp(Int?)
    }
}

extension AnywayElement.Widget {
    
    public var id: ID {
        
        switch self {
        case .core: return .core
        case .otp:  return .otp
        }
    }
    
    public enum ID {
        
        case core, otp
    }
    
    public struct PaymentCore: Equatable {
        
        public let amount: Decimal
        public let currency: Currency
        public let productID: ProductID
        public let productType: ProductType
        
        public init(
            amount: Decimal,
            currency: Currency,
            productID: ProductID,
            productType: ProductType
        ) {
            self.amount = amount
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
