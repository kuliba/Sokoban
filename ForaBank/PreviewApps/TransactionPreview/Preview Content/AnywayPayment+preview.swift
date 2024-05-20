//
//  AnywayPayment+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

extension AnywayPayment {
    
    static let preview: Self = .init(
        elements: [],
        infoMessage: nil,
        isFinalStep: false,
        isFraudSuspected: false,
        puref: .init("iFora||54321")
    )
}
