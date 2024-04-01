//
//  TransactionEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public final class TransactionEffectHandler<Digest, DocumentStatus, OperationDetails, PaymentEffect, PaymentEvent, Update> {
    
    private let initiatePayment: InitiatePayment
    private let makePayment: MakePayment
    private let paymentEffectHandle: PaymentEffectHandle
    private let processPayment: ProcessPayment
    
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

public extension TransactionEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .continue(digest):
            process(digest, dispatch)
            
        case let .initiatePayment(digest):
            initiatePayment(digest, dispatch)
            
        case let .makePayment(verificationCode):
            makePayment(verificationCode, dispatch)
            
        case let .payment(effect):
            handle(effect, dispatch)
        }
    }
}

public extension TransactionEffectHandler {
    
    typealias InitiatePayment = ProcessPayment
    
    typealias ProcessResult = Event.UpdateResult
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias ProcessPayment = (Digest, @escaping ProcessCompletion) -> Void
    
    typealias MakePaymentResult = Event.TransactionResult
    typealias MakePaymentCompletion = (MakePaymentResult) -> Void
    typealias MakePayment = (VerificationCode, @escaping MakePaymentCompletion) -> Void
    
    typealias PaymentDispatch = (PaymentEvent) -> Void
    typealias PaymentEffectHandle = (PaymentEffect, @escaping PaymentDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, Update>
    typealias Effect = TransactionEffect<Digest, PaymentEffect>
}

private extension TransactionEffectHandler {
    
    func process(
        _ digest: Digest,
        _ dispatch: @escaping Dispatch
    ) {
        processPayment(digest) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.updatePayment($0))
        }
    }
    
    func initiatePayment(
        _ digest: Digest,
        _ dispatch: @escaping Dispatch
    ) {
        initiatePayment(digest) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.updatePayment($0))
        }
    }
    
    func makePayment(
        _ verificationCode: VerificationCode,
        _ dispatch: @escaping Dispatch
    ) {
        makePayment(verificationCode) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.completePayment($0))
        }
    }
    
    func handle(
        _ paymentEffect: PaymentEffect,
        _ dispatch: @escaping Dispatch
    ) {
        paymentEffectHandle(paymentEffect) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.payment($0))
        }
    }
}
