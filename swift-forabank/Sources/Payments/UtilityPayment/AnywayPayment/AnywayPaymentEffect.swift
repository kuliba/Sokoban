//
//  AnywayPaymentEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum AnywayPaymentEffect<Payload: Equatable>: Equatable {
    
    case createAnywayTransfer(Payload)
    case makeTransfer(VerificationCode)
}
