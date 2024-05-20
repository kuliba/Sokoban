//
//  AnywayPaymentContext.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Tagged

public struct AnywayPaymentContext: Equatable {
    
    public let payment: AnywayPayment
    public let staged: AnywayPaymentStaged
    public let outline: AnywayPaymentOutline
    
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
