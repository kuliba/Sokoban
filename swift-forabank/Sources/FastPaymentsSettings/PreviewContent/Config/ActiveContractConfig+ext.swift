//
//  ActiveContractConfig+ext.swift
//
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public extension ActiveContractConfig {
    
    static let preview: Self = .init(
        accountLinking: .preview,
        backgroundColor: .orange.opacity(0.1),
        bankDefault: .preview,
        consentList: .preview,
        paymentContract: .preview,
        productSelect: .preview
    )
}
