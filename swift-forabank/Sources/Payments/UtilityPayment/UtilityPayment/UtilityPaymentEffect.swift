//
//  UtilityPaymentEffect.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public enum UtilityPaymentEffect<UtilityPayment: Payment>: Equatable {
    
    case createAnywayTransfer(UtilityPayment)
    case makeTransfer(VerificationCode)
}
