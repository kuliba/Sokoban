//
//  AnywayPaymentContext.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Tagged

public struct AnywayPaymentContext: Equatable {
    
    public let initial: AnywayPayment
    public var payment: AnywayPayment
    public let staged: AnywayPaymentStaged
    public let outline: AnywayPaymentOutline
    public var shouldRestart: Bool
    
    public init(
        initial: AnywayPayment,
        payment: AnywayPayment,
        staged: AnywayPaymentStaged,
        outline: AnywayPaymentOutline,
        shouldRestart: Bool
    ) {
        self.initial = initial
        self.payment = payment
        self.staged = staged
        self.outline = outline
        self.shouldRestart = shouldRestart
    }
}
