//
//  TransactionEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public final class TransactionEffectHandler<DocumentStatus, OperationDetails, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate> {
    
    private let microServices: MicroServices
    
    public init(microServices: MicroServices) {
     
        self.microServices = microServices
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
    
    typealias MicroServices = TransactionEffectHandlerMicroServices<DocumentStatus, OperationDetails, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}

private extension TransactionEffectHandler {
    
    func process(
        _ digest: PaymentDigest,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.processPayment(digest) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.updatePayment($0))
        }
    }
    
    func initiatePayment(
        _ digest: PaymentDigest,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.initiatePayment(digest) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.updatePayment($0))
        }
    }
    
    func makePayment(
        _ verificationCode: VerificationCode,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.makePayment(verificationCode) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.completePayment($0))
        }
    }
    
    func handle(
        _ paymentEffect: PaymentEffect,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.paymentEffectHandle(paymentEffect) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.payment($0))
        }
    }
}
