//
//  PaymentInspector.swift
//  
//
//  Created by Igor Malyarov on 01.04.2024.
//

import AnywayPaymentDomain

public struct PaymentInspector<Payment, PaymentDigest> 
where Payment: RestartablePayment {
    
    public let checkFraud: CheckFraud
    public let getVerificationCode: GetVerificationCode
    public let makeDigest: MakeDigest
    public let resetPayment: ResetPayment
    public let validatePayment: ValidatePayment
    public let wouldNeedRestart: WouldNeedRestart
    
    public init(
        checkFraud: @escaping CheckFraud,
        getVerificationCode: @escaping GetVerificationCode,
        makeDigest: @escaping MakeDigest,
        resetPayment: @escaping ResetPayment,
        validatePayment: @escaping ValidatePayment,
        wouldNeedRestart: @escaping WouldNeedRestart
    ) {
        self.checkFraud = checkFraud
        self.getVerificationCode = getVerificationCode
        self.makeDigest = makeDigest
        self.resetPayment = resetPayment
        self.validatePayment = validatePayment
        self.wouldNeedRestart = wouldNeedRestart
    }
}

public extension PaymentInspector {
    
    typealias CheckFraud = (Payment) -> Bool
    typealias GetVerificationCode = (Payment) -> VerificationCode?
    typealias MakeDigest = (Payment) -> PaymentDigest
    typealias ResetPayment = (Payment) -> Payment
    typealias ValidatePayment = (Payment) -> Bool
    typealias WouldNeedRestart = (Payment) -> Bool
}
