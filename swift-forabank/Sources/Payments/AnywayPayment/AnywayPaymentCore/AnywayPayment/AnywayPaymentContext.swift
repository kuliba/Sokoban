//
//  AnywayPayment+update.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Tagged

public struct AnywayPaymentContext: Equatable {
    
    public let payment: AnywayPayment
    public private(set) var staged: AnywayPayment.Staged
    public private(set) var outline: AnywayPayment.Outline
    
    public init(
        payment: AnywayPayment,
        staged: AnywayPayment.Staged = .init(),
        outline: AnywayPayment.Outline
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
