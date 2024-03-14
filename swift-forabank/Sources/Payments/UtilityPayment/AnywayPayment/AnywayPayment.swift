//
//  AnywayPayment.swift
//
//
//  Created by Igor Malyarov on 07.03.2024.
//

public protocol AnywayPayment: Equatable {
    
    var isFinalStep: Bool { get }
    var verificationCode: VerificationCode? { get }
    var status: PaymentStatus? { get set }
}

public enum PaymentStatus {
    
    case inflight
}
