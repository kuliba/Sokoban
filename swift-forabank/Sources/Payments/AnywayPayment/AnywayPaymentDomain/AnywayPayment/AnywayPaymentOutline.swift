//
//  AnywayPaymentOutline.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation

public struct AnywayPaymentOutline: Equatable {
    
    public let core: PaymentCore
    public let fields: Fields
    public let payload: Payload
    
    public init(
        core: PaymentCore,
        fields: Fields,
        payload: Payload
    ) {
        self.core = core
        self.fields = fields
        self.payload = payload
    }
}

extension AnywayPaymentOutline {
    
    public struct PaymentCore: Equatable {
        
        public let amount: Decimal
        public let currency: String
        public let productID: Int
        public let productType: ProductType
        
        public init(
            amount: Decimal,
            currency: String,
            productID: Int,
            productType: ProductType
        ) {
            self.amount = amount
            self.currency = currency
            self.productID = productID
            self.productType = productType
        }
    }
    
    public typealias Fields = [ID: Value]
    
    public typealias ID = String
    public typealias Value = String
    
    public struct Payload: Equatable {
        
        public let puref: Puref
        public let title: String
        public let subtitle: String?
        public let icon: String?
        
        public init(
            puref: Puref,
            title: String,
            subtitle: String?,
            icon: String?
        ) {
            self.puref = puref
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
        }
        
        public typealias Puref = String
    }
}

extension AnywayPaymentOutline.PaymentCore {
    
    public enum ProductType {
        
        case account, card
    }
}
