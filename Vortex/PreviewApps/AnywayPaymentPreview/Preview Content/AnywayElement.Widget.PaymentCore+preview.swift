//
//  AnywayElement.Widget.PaymentCore+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain

extension AnywayElement.Widget.PaymentCore {
    
    static let preview: Self = .init(
        amount: 12_345.67,
        currency: "RUB",
        productID: 12345678,
        productType: .account
    )
}
