//
//  AnywayPayment+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

extension AnywayPayment {
    
    static let preview: Self = .init(
        elements: [
            .parameter(.stringInput),
            .widget(.otp(nil)),
        ],
        infoMessage: nil,
        isFinalStep: false,
        isFraudSuspected: false,
        puref: .init("iFora||54321")
    )
}
