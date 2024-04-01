//
//  TransactionEffect.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEffect<Digest, PaymentEffect> {
    
    case `continue`(Digest)
    case initiatePayment(Digest)
    case makePayment(VerificationCode)
    case payment(PaymentEffect)
}

extension TransactionEffect: Equatable where Digest: Equatable, PaymentEffect: Equatable {}
