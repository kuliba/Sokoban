//
//  TransactionReducer.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public final class TransactionReducer<DocumentStatus, OperationDetails, Payment, PaymentEffect, PaymentEvent, PaymentDigest, PaymentUpdate> {
    
    private let paymentReduce: PaymentReduce
    private let stagePayment: StagePayment
    private let updatePayment: UpdatePayment
    private let paymentInspector: Inspector

    public init(
        paymentReduce: @escaping PaymentReduce,
        stagePayment: @escaping StagePayment,
        updatePayment: @escaping UpdatePayment,
        paymentInspector: Inspector
    ) {
        self.paymentReduce = paymentReduce
        self.stagePayment = stagePayment
        self.updatePayment = updatePayment
        self.paymentInspector = paymentInspector
    }
}

public extension TransactionReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state.status, event) {
        case (.result, _):
            break
            
        case (_, .dismissRecoverableError):
            reduceDismissRecoverableError(&state)
            
        case (.fraudSuspected, _):
            reduceFraudSuspected(&state, &effect, with: event)
            
        case let (_, .completePayment(transactionResult)):
            reduce(&state, with: transactionResult)
            
        case (_, .continue):
            reduceContinue(&state, &effect)
            
        case (_, .initiatePayment):
            initiatePayment(&state, &effect)
            
        case let (_, .payment(event)):
            reduce(&state, &effect, with: event)
            
        case let (_, .updatePayment(result)):
            reduce(&state, with: result)
            
        default:
            break
        }
        
        return (state, effect)
    }
}

public extension TransactionReducer {
    
    typealias PaymentReduce = (Payment, PaymentEvent) -> (Payment, Effect?)
    typealias StagePayment = (Payment) -> Payment
    typealias UpdatePayment = (Payment, PaymentUpdate) -> Payment
    typealias Inspector = PaymentInspector<Payment, PaymentDigest>
    
    typealias State = Transaction<DocumentStatus, OperationDetails, Payment>
    typealias Event = TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}

private extension TransactionReducer {
    
    func reduceDismissRecoverableError(
        _ state: inout State
    ) {
        guard case .serverError = state.status else { return }

        state.status = nil
    }
    
    func reduceFraudSuspected(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: Event
    ) {
        guard case let .fraud(fraudEvent) = event else { return }
        
        reduce(&state, &effect, with: fraudEvent)
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: Event.Fraud
    ) {
        guard case .fraudSuspected = state.status else { return }
        
        switch event {
        case .cancel:
            state.status = .result(.failure(.fraud(.cancelled)))
            
        case .continue:
            state.status = nil
            
        case .expired:
            state.status = .result(.failure(.fraud(.expired)))
        }
    }
    
    func reduce(
        _ state: inout State,
        with transactionResult: Event.TransactionResult
    ) {
        switch transactionResult {
        case .none:
            state.status = .result(.failure(.transactionFailure))
            
        case let .some(report):
            state.status = .result(.success(report))
        }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: PaymentEvent
    ) {
        let payment: Payment
        (payment, effect) = paymentReduce(state.payment, event)
        state.payment = payment
        state.isValid = paymentInspector.validatePayment(payment)
    }
    
    func reduceContinue(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard state.isValid, state.status == nil else { return }
        
        state.payment = stagePayment(state.payment)
        
        if let verificationCode = paymentInspector.getVerificationCode(state.payment) {
            effect = .makePayment(verificationCode)
        } else {
            if paymentInspector.shouldRestartPayment(state.payment) {
                effect = .initiatePayment(paymentInspector.makeDigest(state.payment))
            } else {
                effect = .continue(paymentInspector.makeDigest(state.payment))
            }
        }
    }
    
    func initiatePayment(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard state.status == nil else { return }
    
        effect = .initiatePayment(paymentInspector.makeDigest(state.payment))
    }
    
    func reduce(
        _ state: inout State,
        with updateResult: Event.PaymentUpdateResult
    ) {
        switch updateResult {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                state.status = .result(.failure(.updatePaymentFailure))
                
            case let .serverError(message):
                state.status = .serverError(message)
            }
            
        case let .success(update):
            let updated = updatePayment(state.payment, update)
            state.payment = updated
            state.isValid = paymentInspector.validatePayment(updated)
            state.status = paymentInspector.checkFraud(updated) ? .fraudSuspected : nil
        }
    }
}
