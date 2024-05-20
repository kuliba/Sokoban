//
//  TransactionEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 17.05.2024.
//

import AnywayPaymentDomain

public struct TransactionEffectHandlerMicroServices<DocumentStatus, OperationDetails, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate> {
    
    public let initiatePayment: InitiatePayment
    public let makePayment: MakePayment
    public let paymentEffectHandle: PaymentEffectHandle
    public let processPayment: ProcessPayment
    
    public init(
        initiatePayment: @escaping InitiatePayment,
        makePayment: @escaping MakePayment,
        paymentEffectHandle: @escaping PaymentEffectHandle,
        processPayment: @escaping ProcessPayment
    ) {
        self.initiatePayment = initiatePayment
        self.makePayment = makePayment
        self.paymentEffectHandle = paymentEffectHandle
        self.processPayment = processPayment
    }
}

public extension TransactionEffectHandlerMicroServices {
    
    typealias InitiatePayment = ProcessPayment
    
    typealias ProcessResult = Event.PaymentUpdateResult
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias ProcessPayment = (PaymentDigest, @escaping ProcessCompletion) -> Void
    
    typealias MakePaymentResult = Event.TransactionResult
    typealias MakePaymentCompletion = (MakePaymentResult) -> Void
    typealias MakePayment = (VerificationCode, @escaping MakePaymentCompletion) -> Void
    
    typealias PaymentDispatch = (PaymentEvent) -> Void
    typealias PaymentEffectHandle = (PaymentEffect, @escaping PaymentDispatch) -> Void
    
    typealias Event = TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}

