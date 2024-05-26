//
//  AnywayPaymentOutline.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Foundation
import Tagged

public struct AnywayPaymentOutline: Equatable {
    
    public let core: PaymentCore
    public let fields: Fields
    
    public init(
        core: PaymentCore,
        fields: Fields
    ) {
        self.core = core
        self.fields = fields
    }
}

extension AnywayPaymentOutline {
    
    public typealias Fields = [ID: Value]
    
    public typealias ID = Tagged<_ID, String>
    public enum _ID {}
    
    public typealias Value = Tagged<_Value, String>
    public enum _Value {}

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
}

extension AnywayPaymentOutline.PaymentCore {
    
    public enum ProductType {
        
        case account, card
    }
}
