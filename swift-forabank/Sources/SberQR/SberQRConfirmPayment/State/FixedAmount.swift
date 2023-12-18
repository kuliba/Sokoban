//
//  FixedAmount.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

public extension SberQRConfirmPaymentStateOf {
    
    struct FixedAmount {
        
        public let header: Header
        public var productSelect: ProductSelect
        public let brandName: Info
        public let amount: Info
        public let recipientBank: Info
        public let bottom: Button
        
        public init(
            header: Header,
            productSelect: ProductSelect,
            brandName: Info,
            amount: Info,
            recipientBank: Info,
            bottom: Button
        ) {
            self.header = header
            self.productSelect = productSelect
            self.brandName = brandName
            self.amount = amount
            self.recipientBank = recipientBank
            self.bottom = bottom
        }
    }
}

public extension SberQRConfirmPaymentStateOf.FixedAmount {
    
    typealias Button = GetSberQRDataResponse.Parameter.Button
}

extension SberQRConfirmPaymentStateOf.FixedAmount: Equatable where Info: Equatable {}
