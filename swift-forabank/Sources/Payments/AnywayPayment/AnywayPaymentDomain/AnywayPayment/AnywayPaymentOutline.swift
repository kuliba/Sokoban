//
//  AnywayPaymentOutline.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation

public struct AnywayPaymentOutline: Equatable {
    
    public let amount: Decimal?
    public let product: Product
    public let fields: Fields
    public let payload: Payload
    
    public init(
        amount: Decimal?,
        product: Product,
        fields: Fields,
        payload: Payload
    ) {
        self.amount = amount
        self.product = product
        self.fields = fields
        self.payload = payload
    }
}

extension AnywayPaymentOutline {
    
    public struct Product: Equatable {
        
        public let currency: String
        public let productID: Int
        public let productType: ProductType
        
        public init(
            currency: String,
            productID: Int,
            productType: ProductType
        ) {
            self.currency = currency
            self.productID = productID
            self.productType = productType
        }
        
        public enum ProductType {
            
            case account, card
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
