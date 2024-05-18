//
//  AnywayPaymentContext+stage.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentDomain
import Tagged

extension AnywayPaymentContext {
    
    public func stage() -> Self {
        
        return .init(
            payment: payment,
            staged: payment.staged(),
            outline: outline.update(with: payment)
        )
    }
}
