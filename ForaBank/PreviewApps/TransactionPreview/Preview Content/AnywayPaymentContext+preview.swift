//
//  AnywayPaymentContext+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentContext {
    
    static let preview: Self = .init(
        payment: .preview,
        staged: .init(),
        outline: .preview
    )
}
