//
//  TransactionReducer.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

import AnywayPaymentDomain

public final class TransactionReducer<Report, Payment, PaymentEvent, PaymentEffect, PaymentDigest, PaymentUpdate> 
where Payment: RestartablePayment {
    
    private let paymentReduce: PaymentReduce
    private let paymentInspector: Inspector

    public init(
        paymentReduce: @escaping PaymentReduce,
        paymentInspector: Inspector
    ) {
        self.paymentReduce = paymentReduce
        self.paymentInspector = paymentInspector
    }
    
    public typealias PaymentReduce = (Payment, PaymentEvent) -> (Payment, PaymentEffect?)
    public typealias Inspector = PaymentInspector<Payment, PaymentDigest, PaymentUpdate>
}

public extension TransactionReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
    
        reduce(&state, &effect, with: event)
        
        return (state, effect)
    }
    
    typealias State = Transaction<Payment, Status>
    typealias Event = TransactionEvent<Report, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>

    typealias Status = TransactionStatus<Payment, PaymentUpdate, Report>
}

private extension TransactionReducer {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: Event
    ) {
        switch (state.status, event) {
        case let (.awaitingPaymentRestartConfirmation, .paymentRestartConfirmation(shouldRestartPayment)):
            reduce(&state, shouldRestartPayment: shouldRestartPayment)
            
        case (.result, _):
            break
            
        case (_, .dismissRecoverableError):
            reduceDismissRecoverableError(&state)
            
        case let (.fraudSuspected, .fraud(fraudEvent)):
            reduce(&state, with: fraudEvent)
            
        case (.fraudSuspected,_):
            break
            
        case let (_, .verificationCode(verificationCode)):
            reduce(&state, &effect, with: verificationCode)
            
        case let (_, .completePayment(result)):
            reduce(&state, with: result)
            
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
    }

    func reduce(
        _ state: inout State,
        shouldRestartPayment: Bool
    ) {
        guard case .awaitingPaymentRestartConfirmation = state.status
        else { return }
        
        if shouldRestartPayment {
            state.context.shouldRestart = true
        } else {
            state.context = paymentInspector.rollbackPayment(state.context)
        }
        
        state.isValid = paymentInspector.validatePayment(state.context)
        state.status = nil
    }
    
    func reduceDismissRecoverableError(
        _ state: inout State
    ) {
        guard case .serverError = state.status else { return }
        
        state.status = nil
    }
    
    func reduce(
        _ state: inout State,
        with fraudEvent: FraudEvent
    ) {
        guard case let .fraudSuspected(update) = state.status
        else { return }
        
        switch fraudEvent {
        case .cancel:
            state.status = .result(.failure(.fraud(.cancelled)))
            
        case .consent:
            updateState(&state, with: update)
            
        case .expired:
            state.status = .result(.failure(.fraud(.expired)))
        }
    }
    
    func reduce(
        _ state: inout State,
        with result: Event.TransactionResult
    ) {
        switch result {
        case let .failure(.otpFailure(message)):
            state.context = paymentInspector.handleOTPFailure(state.context, message)
            state.status = nil
            
        case let .failure(.terminal(message)):
            state.status = .result(.failure(.transactionFailure(message)))
            
        case let .success(report):
            state.status = .result(.success(report))
        }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with event: PaymentEvent
    ) {
        let (payment, paymentEffect) = paymentReduce(state.context, event)
        state.context = payment
        effect = paymentEffect.map(Effect.payment)
        
        let shouldConfirmRestart = paymentInspector.wouldNeedRestart(payment) && !state.context.shouldRestart
        if shouldConfirmRestart {
            state.status = .awaitingPaymentRestartConfirmation
        }
        
        state.isValid = paymentInspector.validatePayment(payment)
    }
    
    func reduceContinue(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard state.status == nil else {
#if DEBUG || MOCK
            print("===>>> can't continue with non-nil status \(String(describing: state.status))", #file, #line)
#endif
            return
        }
        
        guard state.isValid else {
#if DEBUG || MOCK
            print("===>>> can't continue with invalid transaction", #file, #line)
#endif
            return
        }
        
        state.context = paymentInspector.stagePayment(state.context)
        
        if let verificationCode = paymentInspector.getVerificationCode(state.context) {
            
            effect = .makePayment(verificationCode)
        } else {
            
            let digest = paymentInspector.makeDigest(state.context)
            
            if state.context.shouldRestart {
                state.context = paymentInspector.resetPayment(state.context)
                effect = .initiatePayment(digest)
            } else {
                effect = .continue(digest)
            }
        }
        
        state.status = .inflight
    }
    
    func initiatePayment(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard state.status == nil else { return }
        
        state.status = .inflight
        effect = .initiatePayment(paymentInspector.makeDigest(state.context))
    }
    
    func reduce(
        _ state: inout State,
        with updateResult: Event.UpdatePaymentResult
    ) {
        state.context.shouldRestart = false
        
        switch updateResult {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case let .connectivityError(message):
                state.status = .result(.failure(.updatePaymentFailure(message)))
                
            case let .serverError(message):
                state.status = .serverError(message)
            }
            
        case let .success(update):
            
            if paymentInspector.checkFraud(update) {
                // postpone payment update
                state.status = .fraudSuspected(update)
            } else {
                updateState(&state, with: update)
            }
        }
    }
    
    private func reduce(
    _ state: inout State,
    _ effect: inout Effect?,
    with verificationCode: Event.VerificationCode
    ) {
        switch verificationCode {
        case let .receive(result):
            switch result {
            case let .failure(serviceFailure):
                state.status = .result(.failure(.transactionFailure(serviceFailure.message)))

            case .success:
                break
            }
            
        case .request:
            effect = .getVerificationCode
        }
    }
    
    private func updateState(
        _ state: inout State,
        with update: PaymentUpdate
    ) {
        let updated = paymentInspector.updatePayment(state.context, update)
        state.context = updated
        state.isValid = paymentInspector.validatePayment(updated)
        state.status = nil
    }
}
