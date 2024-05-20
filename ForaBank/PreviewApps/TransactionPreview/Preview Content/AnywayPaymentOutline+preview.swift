//
//  AnywayPaymentOutline+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentOutline {
    
    static let preview: Self = .init(
        core: .preview,
        fields: [:]
    )
}

private extension AnywayPaymentOutline.PaymentCore {
    
    static let preview: Self = .init(
        amount: 123.45,
        currency: "RUB",
        productID: 987654321,
        productType: .account
    )
}
