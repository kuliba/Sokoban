//
//  PaymentInspector.swift
//
//
//  Created by Igor Malyarov on 01.04.2024.
//

import AnywayPaymentDomain

public struct PaymentInspector<Payment, PaymentDigest, PaymentUpdate>
where Payment: RestartablePayment {
    
    public let checkFraud: CheckFraud
    public let getVerificationCode: GetVerificationCode
    public let makeDigest: MakeDigest
    public let resetPayment: ResetPayment
    public let rollbackPayment: RollbackPayment
    public let stagePayment: StagePayment
    public let updatePayment: UpdatePayment
    public let validatePayment: ValidatePayment
    public let wouldNeedRestart: WouldNeedRestart
    
    public init(
        checkFraud: @escaping CheckFraud,
        getVerificationCode: @escaping GetVerificationCode,
        makeDigest: @escaping MakeDigest,
        resetPayment: @escaping ResetPayment,
        rollbackPayment: @escaping RollbackPayment,
        stagePayment: @escaping StagePayment,
        updatePayment: @escaping UpdatePayment,
        validatePayment: @escaping ValidatePayment,
        wouldNeedRestart: @escaping WouldNeedRestart
    ) {
        self.checkFraud = checkFraud
        self.getVerificationCode = getVerificationCode
        self.makeDigest = makeDigest
        self.resetPayment = resetPayment
        self.rollbackPayment = rollbackPayment
        self.stagePayment = stagePayment
        self.updatePayment = updatePayment
        self.validatePayment = validatePayment
        self.wouldNeedRestart = wouldNeedRestart
    }
}

public extension PaymentInspector {
    
    typealias CheckFraud = (PaymentUpdate) -> Bool
    typealias GetVerificationCode = (Payment) -> VerificationCode?
    typealias MakeDigest = (Payment) -> PaymentDigest
    typealias ResetPayment = (Payment) -> Payment
    typealias RollbackPayment = (Payment) -> Payment
    typealias StagePayment = (Payment) -> Payment
    typealias UpdatePayment = (Payment, PaymentUpdate) -> Payment
    typealias ValidatePayment = (Payment) -> Bool
    typealias WouldNeedRestart = (Payment) -> Bool
}
