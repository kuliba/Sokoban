//
//  AnywayPaymentContext+resetPayment.swift
//  
//
//  Created by Igor Malyarov on 18.06.2024.
//

import AnywayPaymentDomain

public extension AnywayPaymentContext {
    
    func resetPayment() -> Self {
        
        return .init(
            initial: initial,
            payment: initial,
            staged: .init(),
            outline: outline,
            shouldRestart: shouldRestart
        )
    }
}
