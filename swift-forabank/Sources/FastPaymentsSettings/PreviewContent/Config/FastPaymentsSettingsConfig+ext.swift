//
//  FastPaymentsSettingsConfig+ext.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public extension FastPaymentsSettingsConfig {
    
    static let preview: Self = .init(
        accountLinking: .preview,
        backgroundColor: .orange.opacity(0.5),
        bankDefault: .preview,
        carousel: .preview,
        consentList: .preview,
        paymentContract: .preview,
        productSelect: .preview
    )
}
