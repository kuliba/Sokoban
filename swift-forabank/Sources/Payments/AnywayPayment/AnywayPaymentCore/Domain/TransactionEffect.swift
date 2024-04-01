//
//  TransactionEffect.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEffect<PaymentDigest, PaymentEffect> {
    
    case `continue`(PaymentDigest)
    case initiatePayment(PaymentDigest)
    case makePayment(VerificationCode)
    case payment(PaymentEffect)
}

extension TransactionEffect: Equatable where PaymentDigest: Equatable, PaymentEffect: Equatable {}
