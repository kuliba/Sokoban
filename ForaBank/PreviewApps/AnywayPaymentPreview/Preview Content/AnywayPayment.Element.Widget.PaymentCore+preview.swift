//
//  AnywayPayment.AnywayElement.Widget.PaymentCore+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain

extension AnywayPayment.AnywayElement.Widget.PaymentCore {
    
    static let preview: Self = .init(
        amount: 12_345.67,
        currency: "RUB",
        productID: .accountID(12345678)
    )
}
