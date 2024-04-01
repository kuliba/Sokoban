//
//  TransactionEffect.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum TransactionEffect<Digest, ParameterEffect> {
    
    case `continue`(Digest)
    case initiatePayment(Digest)
    case makePayment(VerificationCode)
    case parameter(ParameterEffect)
}

extension TransactionEffect: Equatable where Digest: Equatable, ParameterEffect: Equatable {}
