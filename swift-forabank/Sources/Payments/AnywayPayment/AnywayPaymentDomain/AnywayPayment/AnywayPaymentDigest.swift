//
//  AnywayPaymentDigest.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import Foundation
import Tagged

public struct AnywayPaymentDigest: Equatable {
    
    public let additional: [Additional]
    public let core: PaymentCore?
    public let puref: Puref
    
    public init(
        additional: [Additional],
        core: PaymentCore?,
        puref: Puref
    ) {
        self.additional = additional
        self.core = core
        self.puref = puref
    }
}

extension AnywayPaymentDigest {
    
    public struct Additional: Equatable {
        
        public let fieldID: Int
        public let fieldName: String
        public let fieldValue: String
        
        public init(
            fieldID: Int,
            fieldName: String,
            fieldValue: String
        ) {
            self.fieldID = fieldID
            self.fieldName = fieldName
            self.fieldValue = fieldValue
        }
    }
    
    public struct PaymentCore: Equatable {
        
        public let amount: Decimal
        public let currency: Currency
        public let productID: ProductID
        public let productType: ProductType
        
        public init(
            amount: Decimal,
            currency: Currency,
            productID: Int,
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
    
    public typealias Puref = String
}
