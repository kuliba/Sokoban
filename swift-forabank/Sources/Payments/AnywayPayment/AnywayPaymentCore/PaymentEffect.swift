//
//  PaymentEffect.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public enum PaymentEffect<Digest> {
    
    case `continue`(Digest)
    case makePayment
}

extension PaymentEffect: Equatable where Digest: Equatable {}
