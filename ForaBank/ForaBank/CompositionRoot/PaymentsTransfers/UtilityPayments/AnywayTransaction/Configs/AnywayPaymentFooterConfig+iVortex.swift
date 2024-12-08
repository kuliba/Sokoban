//
//  AnywayPaymentFooterConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.05.2024.
//

import PaymentComponents

extension AnywayPaymentFooterConfig {
    
    static let iVortex: Self = .init(
        amountConfig: .iVortex,
        buttonConfig: .iVortexFooter
    )
}
