//
//  PaymentInspector.swift
//  
//
//  Created by Igor Malyarov on 01.04.2024.
//

import AnywayPaymentDomain

#warning("rename to PaymentDigestor")
public struct PaymentInspector<Payment, PaymentDigest> {
    
    public let checkFraud: CheckFraud
    public let getVerificationCode: GetVerificationCode
    public let makeDigest: MakeDigest
    public let shouldRestartPayment: ShouldRestartPayment
    public let validatePayment: ValidatePayment
    
    public init(
        checkFraud: @escaping CheckFraud,
        getVerificationCode: @escaping GetVerificationCode,
        makeDigest: @escaping MakeDigest,
        shouldRestartPayment: @escaping ShouldRestartPayment,
        validatePayment: @escaping ValidatePayment
    ) {
        self.checkFraud = checkFraud
        self.getVerificationCode = getVerificationCode
        self.makeDigest = makeDigest
        self.shouldRestartPayment = shouldRestartPayment
        self.validatePayment = validatePayment
    }
}

public extension PaymentInspector {
    
    typealias CheckFraud = (Payment) -> Bool
    typealias GetVerificationCode = (Payment) -> VerificationCode?
    typealias MakeDigest = (Payment) -> PaymentDigest
    typealias ShouldRestartPayment = (Payment) -> Bool
    typealias ValidatePayment = (Payment) -> Bool
}
