//
//  AnywayPaymentContext+staging.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentDomain

extension AnywayPaymentContext {
    
    public func staging() -> Self {
        
        return .init(
            initial: initial,
            payment: payment,
            staged: payment.getStaged(),
            outline: outline.updating(with: payment),
            shouldRestart: shouldRestart
        )
    }
}
