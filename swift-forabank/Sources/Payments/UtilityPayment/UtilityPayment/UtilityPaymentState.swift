//
//  UtilityPaymentState.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public struct UtilityPaymentState: Equatable {
    
    public var prePayment: PrePaymentState
    
    public init(
        prePayment: PrePaymentState = .selecting
    ) {
        self.prePayment = prePayment
    }
}
