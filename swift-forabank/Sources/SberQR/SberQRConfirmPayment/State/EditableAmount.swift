//
//  EditableAmount.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

public extension SberQRConfirmPaymentStateOf {
    
    struct EditableAmount {
        
        public let header: Header
        public var productSelect: ProductSelect
        public let brandName: Info
        public let recipientBank: Info
        public let currency: DataString
        public var bottom: Amount
        
        public init(
            header: Header,
            productSelect: ProductSelect,
            brandName: Info,
            recipientBank: Info,
            currency: DataString,
            bottom: Amount
        ) {
            self.header = header
            self.productSelect = productSelect
            self.brandName = brandName
            self.recipientBank = recipientBank
            self.currency = currency
            self.bottom = bottom
        }
    }
}

public extension SberQRConfirmPaymentStateOf.EditableAmount {
    
    typealias Amount = GetSberQRDataResponse.Parameter.Amount
    typealias DataString = GetSberQRDataResponse.Parameter.DataString
}

extension SberQRConfirmPaymentStateOf.EditableAmount: Equatable where Info: Equatable {}
