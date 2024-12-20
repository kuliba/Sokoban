//
//  TransactionEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import AnywayPaymentDomain

public final class TransactionEffectHandler<TransactionReport, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate> {
    
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
            
        case .getVerificationCode:
            getVerificationCode(dispatch)
            
        case let .initiatePayment(digest):
            initiatePayment(digest, dispatch)
            
        case let .makePayment(verificationCode):
            makePayment(verificationCode, dispatch)
            
        case let .payment(effect):
            handlePaymentEffect(effect, dispatch)
        }
    }
}

public extension TransactionEffectHandler {
    
    typealias MicroServices = TransactionEffectHandlerMicroServices<TransactionReport, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TransactionEvent<TransactionReport, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}

private extension TransactionEffectHandler {
    
    func getVerificationCode(
        _ dispatch: @escaping Dispatch
    ) {
        microServices.getVerificationCode {
            
            dispatch(.verificationCode(.receive($0)))
        }
    }
    
    func handlePaymentEffect(
        _ paymentEffect: PaymentEffect,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.paymentEffectHandle(paymentEffect) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.payment($0))
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
    
    func process(
        _ digest: PaymentDigest,
        _ dispatch: @escaping Dispatch
    ) {
        microServices.processPayment(digest) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.updatePayment($0))
        }
    }
}
