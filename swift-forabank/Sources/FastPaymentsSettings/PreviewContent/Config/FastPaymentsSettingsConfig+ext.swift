//
//  FastPaymentsSettingsConfig+ext.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public extension FastPaymentsSettingsConfig {
    
    static let preview: Self = .init(
        bankDefault: .preview,
        paymentContract: .preview,
        productSelect: .preview
    )
}
