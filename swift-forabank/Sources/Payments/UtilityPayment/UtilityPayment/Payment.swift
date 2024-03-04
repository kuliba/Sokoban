//
//  Payment.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

public protocol Payment: Equatable {
    
    var isFinalStep: Bool { get }
    var verificationCode: VerificationCode? { get }
    var status: PaymentStatus? { get set }
}
