//
//  AnywayPayment+update.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentDomain
import Tagged

public struct AnywayPaymentContext: Equatable {
    
    public let payment: AnywayPayment
    public private(set) var staged: AnywayPaymentStaged
    public private(set) var outline: AnywayPaymentOutline
    
    public init(
        payment: AnywayPayment,
        staged: AnywayPaymentStaged = .init(),
        outline: AnywayPaymentOutline
    ) {
        self.payment = payment
        self.staged = staged
        self.outline = outline
    }
}

extension AnywayPaymentContext {
    
    public mutating func stage() {
        
        staged = payment.staged()
        outline = outline.update(with: payment)
    }
}
