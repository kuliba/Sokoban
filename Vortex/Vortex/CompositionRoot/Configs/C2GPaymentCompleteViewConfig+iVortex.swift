//
//  C2GPaymentCompleteViewConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

extension C2GPaymentCompleteViewConfig {
    
    static let iVortex: Self = .init(
        spacing: 24,
        merchantName: .init(
            textFont: .textBodyMR14180(),
            textColor: .textPlaceholder
        ),
        purpose: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        )
    )
}
