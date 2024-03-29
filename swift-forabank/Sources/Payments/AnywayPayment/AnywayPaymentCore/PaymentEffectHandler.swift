//
//  PaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public final class PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, Update> {
    
    private let process: Process
    private let makePayment: MakePayment
    
    public init(
        process: @escaping Process,
        makePayment: @escaping MakePayment
    ) {
        self.process = process
        self.makePayment = makePayment
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
            
        case let .makePayment(verificationCode):
            makePayment(verificationCode, dispatch)
        }
    }
}

public extension PaymentEffectHandler {
    
    typealias ProcessResult = Event.UpdateResult
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias Process = (Digest, @escaping ProcessCompletion) -> Void
    
    typealias MakePaymentResult = Event.TransactionResult
    typealias MakePaymentCompletion = (MakePaymentResult) -> Void
    typealias MakePayment = (VerificationCode, @escaping MakePaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentEvent<DocumentStatus, OperationDetails, Update>
    typealias Effect = PaymentEffect<Digest>
}

private extension PaymentEffectHandler {
    
    func process(
        _ digest: Digest,
        _ dispatch: @escaping Dispatch
    ) {
        process(digest) { [weak self] in
            
            guard self != nil else { return }
            
            dispatch(.update($0))
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
}
