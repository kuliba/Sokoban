//
//  PaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public final class PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Update> {
    
    private let initiatePayment: InitiatePayment
    private let makePayment: MakePayment
    private let parameterEffectHandle: ParameterEffectHandle
    private let processPayment: ProcessPayment
    
    public init(
        initiatePayment: @escaping InitiatePayment,
        makePayment: @escaping MakePayment,
        parameterEffectHandle: @escaping ParameterEffectHandle,
        processPayment: @escaping ProcessPayment
    ) {
        self.initiatePayment = initiatePayment
        self.makePayment = makePayment
        self.parameterEffectHandle = parameterEffectHandle
        self.processPayment = processPayment
    }
}

public extension PaymentEffectHandler {
    
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
            
        case let .parameter(parameterEffect):
            handle(parameterEffect, dispatch)
        }
    }
}

public extension PaymentEffectHandler {
    
    typealias InitiatePayment = ProcessPayment
    
    typealias ProcessResult = Event.UpdateResult
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias ProcessPayment = (Digest, @escaping ProcessCompletion) -> Void
    
    typealias MakePaymentResult = Event.TransactionResult
    typealias MakePaymentCompletion = (MakePaymentResult) -> Void
    typealias MakePayment = (VerificationCode, @escaping MakePaymentCompletion) -> Void
    
    typealias ParameterDispatch = (ParameterEvent) -> Void
    typealias ParameterEffectHandle = (ParameterEffect, @escaping ParameterDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update>
    typealias Effect = PaymentEffect<Digest, ParameterEffect>
}

private extension PaymentEffectHandler {
    
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
        _ parameterEffect: ParameterEffect,
        _ dispatch: @escaping Dispatch
    ) {
        parameterEffectHandle(parameterEffect) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.parameter($0))
        }
    }
}
