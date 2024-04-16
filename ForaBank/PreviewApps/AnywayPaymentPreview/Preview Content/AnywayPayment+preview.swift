//
//  AnywayPayment+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore

extension AnywayPayment {
    
    static let preview: Self = .init(
        elements: .preview,
        infoMessage: nil,
        isFinalStep: false,
        isFraudSuspected: false,
        puref: "iFora || abc"
    )
}
