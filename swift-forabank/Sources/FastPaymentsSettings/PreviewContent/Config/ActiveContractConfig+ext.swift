//
//  ActiveContractConfig+ext.swift
//  
//
//  Created by Igor Malyarov on 25.01.2024.
//

import ProductSelectComponent

public extension ActiveContractConfig {
    
    static let preview: Self = .init(
        backgroundColor: .orange.opacity(0.1),
        bankDefault: .preview,
        paymentContract: .preview,
        productSelect: .preview
    )
}
