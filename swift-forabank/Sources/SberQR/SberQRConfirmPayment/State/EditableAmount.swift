//
//  EditableAmount.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

import PaymentComponents

public extension SberQRConfirmPaymentStateOf {
    
    struct EditableAmount {
        
        public let header: Header
        public var productSelect: ProductSelect
        public let brandName: Info
        public let recipientBank: Info
        public let currency: DataString
        public var amount: Amount
        
        public init(
            header: Header,
            productSelect: ProductSelect,
            brandName: Info,
            recipientBank: Info,
            currency: DataString,
            amount: Amount
        ) {
            self.header = header
            self.productSelect = productSelect
            self.brandName = brandName
            self.recipientBank = recipientBank
            self.currency = currency
            self.amount = amount
        }
    }
}

public extension SberQRConfirmPaymentStateOf.EditableAmount {
    
    typealias DataString = GetSberQRDataResponse.Parameter.DataString
}

extension SberQRConfirmPaymentStateOf.EditableAmount: Equatable where Info: Equatable {}
