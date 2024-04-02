//
//  AnywayPaymentDigest.swift
//  
//
//  Created by Igor Malyarov on 02.04.2024.
//

import Foundation
import Tagged

public struct AnywayPaymentDigest: Equatable {
    
    // Признак проверки операции (если check="true", то OTP не отправляется, если check="false" - OTP отправляется)
    public let check: Bool
    public let amount: Amount?
    public let payer: Payer?
    public let comment: String?
    public let puref: Puref?
    public let additionals: [Additional]
    public let mcc: MCC?
    
    public init(
        check: Bool, 
        amount: Amount?,
        payer: Payer?,
        comment: String?,
        puref: Puref?,
        additionals: [Additional],
        mcc: MCC?
    ) {
        self.check = check
        self.amount = amount
        self.payer = payer
        self.comment = comment
        self.puref = puref
        self.additionals = additionals
        self.mcc = mcc
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
    
    public struct Amount: Equatable {
        
        public let value: Decimal
        public let currency: Currency
        
        public init(
            value: Decimal, 
            currency: Currency
        ) {
            self.value = value
            self.currency = currency
        }
    }
    
    public struct Payer: Equatable {
        
        public let product: Product // if just product field is left, remove excessive hierarchy
        public let phoneNumber: PhoneNumber? // remove?
        public let inn: INN? // remove?
        
        public init(
            product: Product, 
            phoneNumber: PhoneNumber?, 
            inn: INN?
        ) {
            self.product = product
            self.phoneNumber = phoneNumber
            self.inn = inn
        }
    }
}

public extension AnywayPaymentDigest.Amount {
    
    typealias Currency = Tagged<_Currency, String>
    enum _Currency {}
}

public extension AnywayPaymentDigest.Payer {
    
    enum Product: Equatable {
        
        case account(AccountID)
        case card(CardID)
    }
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    typealias INN = Tagged<_INN, String>
    enum _INN {}
}

public extension AnywayPaymentDigest.Payer.Product {
    
    typealias AccountID = Tagged<_AccountID, Int>
    enum _AccountID {}
    
    typealias CardID = Tagged<_CardID, Int>
    enum _CardID {}
}
