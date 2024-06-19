//
//  TransactionEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 17.05.2024.
//

import AnywayPaymentDomain

public struct TransactionEffectHandlerMicroServices<TransactionReport, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate> {
    
    public let getVerificationCode: GetVerificationCode
    public let initiatePayment: InitiatePayment
    public let makePayment: MakePayment
    public let paymentEffectHandle: PaymentEffectHandle
    public let processPayment: ProcessPayment
    
    public init(
        getVerificationCode: @escaping GetVerificationCode,
        initiatePayment: @escaping InitiatePayment,
        makePayment: @escaping MakePayment,
        paymentEffectHandle: @escaping PaymentEffectHandle,
        processPayment: @escaping ProcessPayment
    ) {
        self.getVerificationCode = getVerificationCode
        self.initiatePayment = initiatePayment
        self.makePayment = makePayment
        self.paymentEffectHandle = paymentEffectHandle
        self.processPayment = processPayment
    }
}

public extension TransactionEffectHandlerMicroServices {
    
    typealias GetVerificationCodeResult = Event.VerificationCode.GetVerificationCodeResult
    typealias GetVerificationCodeCompletion = (GetVerificationCodeResult) -> Void
    typealias GetVerificationCode = (@escaping GetVerificationCodeCompletion) -> Void

    typealias InitiatePayment = ProcessPayment
    
    typealias ProcessResult = Event.UpdatePaymentResult
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias ProcessPayment = (PaymentDigest, @escaping ProcessCompletion) -> Void
    
    typealias MakePaymentCompletion = (TransactionReport?) -> Void
    typealias MakePayment = (VerificationCode, @escaping MakePaymentCompletion) -> Void
    
    typealias PaymentDispatch = (PaymentEvent) -> Void
    typealias PaymentEffectHandle = (PaymentEffect, @escaping PaymentDispatch) -> Void
    
    typealias Event = TransactionEvent<TransactionReport, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}
