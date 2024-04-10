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
    public let amount: Decimal?
    // Признак проверки операции (если check="true", то OTP не отправляется, если check="false" - OTP отправляется)
    public let check: Bool
    public let comment: String?
    public let mcc: MCC?
    public let product: Product?
    public let puref: Puref?
    
    public init(
        additional: [Additional],
        amount: Decimal?,
        check: Bool,
        comment: String?,
        mcc: MCC?,
        product: Product?,
        puref: Puref?
    ) {
        self.additional = additional
        self.amount = amount
        self.check = check
        self.comment = comment
        self.mcc = mcc
        self.product = product
        self.puref = puref
    }
}

public extension AnywayPaymentDigest {
    
    typealias MCC = Tagged<_MCC, String>
    enum _MCC {}
    
    typealias Puref = Tagged<_Puref, String>
    enum _Puref {}
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
}

public extension AnywayPaymentDigest {
    
    struct Product: Equatable {
        
        public let type: ProductType
        public let currency: Currency
        
        public init(
            type: ProductType,
            currency: Currency
        ) {
            self.type = type
            self.currency = currency
        }
    }
}

public extension AnywayPaymentDigest.Product {
    
    typealias Currency = Tagged<_Currency, String>
    enum _Currency {}
    
    enum ProductType: Equatable {
        
        case account(AccountID)
        case card(CardID)
    }
}

public extension AnywayPaymentDigest.Product.ProductType {
    
    typealias AccountID = Tagged<_AccountID, Int>
    enum _AccountID {}
    
    typealias CardID = Tagged<_CardID, Int>
    enum _CardID {}
}
