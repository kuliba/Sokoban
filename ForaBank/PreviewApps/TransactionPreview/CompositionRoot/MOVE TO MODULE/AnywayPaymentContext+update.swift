//
//  AnywayPaymentContext+update.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentDomain

#warning("move to module, add tests")
extension AnywayPaymentContext {
    
    func update(
        with update: AnywayPaymentUpdate,
        and outline: AnywayPaymentOutline
    ) -> Self {
        
        let payment = payment.update(with: update, and: outline)
        
        return .init(payment: payment, staged: staged, outline: outline)
    }
}
