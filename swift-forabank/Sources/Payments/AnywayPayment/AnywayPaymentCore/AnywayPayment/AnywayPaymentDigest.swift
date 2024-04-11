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
        
        public init(
            amount: Decimal,
            currency: Currency,
            productID: ProductID
        ) {
            self.amount = amount
            self.currency = currency
            self.productID = productID
        }
    }
    
    public typealias Puref = Tagged<_Puref, String>
    public enum _Puref {}
}

public extension AnywayPaymentDigest.PaymentCore {
    
    typealias Currency = Tagged<_Currency, String>
    enum _Currency {}
    
    enum ProductID: Equatable {
        
        case account(AccountID)
        case card(CardID)
    }
}

public extension AnywayPaymentDigest.PaymentCore.ProductID {
    
    typealias AccountID = Tagged<_AccountID, Int>
    enum _AccountID {}
    
    typealias CardID = Tagged<_CardID, Int>
    enum _CardID {}
}
