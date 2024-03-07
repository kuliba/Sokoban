//
//  AnywayPaymentEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum AnywayPaymentEffect<AnywayPayment: Equatable>: Equatable {
    
    case createAnywayTransfer(AnywayPayment)
    case makeTransfer(VerificationCode)
}
