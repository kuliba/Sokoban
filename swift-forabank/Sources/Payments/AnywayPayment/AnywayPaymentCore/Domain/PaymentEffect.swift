//
//  PaymentEffect.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum PaymentEffect<Digest, ParameterEffect> {
    
    case `continue`(Digest)
    case initiatePayment(Digest)
    case makePayment(VerificationCode)
    case parameter(ParameterEffect)
}

extension PaymentEffect: Equatable where Digest: Equatable, ParameterEffect: Equatable {}
