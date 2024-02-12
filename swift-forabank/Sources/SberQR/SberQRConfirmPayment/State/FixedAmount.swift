//
//  FixedAmount.swift
//
//
//  Created by Igor Malyarov on 17.12.2023.
//

import PaymentComponents

public struct FixedAmount<Info> {
    
    public let header: Header
    public var productSelect: ProductSelect
    public let brandName: Info
    public let amount: Info
    public let recipientBank: Info
    public let button: Button
    
    public init(
        header: Header,
        productSelect: ProductSelect,
        brandName: Info,
        amount: Info,
        recipientBank: Info,
        button: Button
    ) {
        self.header = header
        self.productSelect = productSelect
        self.brandName = brandName
        self.amount = amount
        self.recipientBank = recipientBank
        self.button = button
    }
}

extension FixedAmount: Equatable where Info: Equatable {}
