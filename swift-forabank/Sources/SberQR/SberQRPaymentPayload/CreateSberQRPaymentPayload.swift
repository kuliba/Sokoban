//
//  CreateSberQRPaymentPayload.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import Tagged

public struct CreateSberQRPaymentPayload: Equatable {
    
    public let qrLink: URL
    public let product: Product
    public let amount: Amount?
    
    public init(
        qrLink: URL,
        product: Product,
        amount: Amount?
    ) {
        self.qrLink = qrLink
        self.product = product
        self.amount = amount
    }
}

public extension CreateSberQRPaymentPayload {
    
    enum Product: Equatable {
        
        case card(CardID)
        case account(AccountID)
        
        public typealias CardID = Tagged<_CardID, Int>
        public enum _CardID {}
        
        public typealias AccountID = Tagged<_AccountID, Int>
        public enum _AccountID {}
    }
    
    struct Amount: Equatable {
        
        public let amount: Decimal
        public let currency: Currency
        
        public init(amount: Decimal, currency: Currency) {
            
            self.amount = amount
            self.currency = currency
        }
        
        public typealias Currency = Tagged<_Currency, String>
        public enum _Currency {}
    }
}
