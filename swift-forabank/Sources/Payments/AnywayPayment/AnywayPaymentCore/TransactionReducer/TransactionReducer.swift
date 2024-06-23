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
            
        case let (_, .completePayment(report)):
            reduce(&state, with: report)
            
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
    
    typealias PaymentReduce = (Payment, PaymentEvent) -> (Payment, PaymentEffect?)
    typealias StagePayment = (Payment) -> Payment
    typealias UpdatePayment = (Payment, PaymentUpdate) -> Payment
    typealias Inspector = PaymentInspector<Payment, PaymentDigest, PaymentUpdate>
    
    typealias State = Transaction<Payment, TransactionStatus<Payment, PaymentUpdate, Report>>
    typealias Event = TransactionEvent<Report, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}

private extension TransactionReducer {
    
    func reduce(
        _ state: inout State,
        shouldRestartPayment: Bool
    ) {
        guard case .awaitingPaymentRestartConfirmation = state.status
        else { return }
        
        if shouldRestartPayment {
            state.context.shouldRestart = true
        } else {
            state.context = paymentInspector.restorePayment(state.context)
            state.isValid = paymentInspector.validatePayment(state.context)
        }
        
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
        with report: Report?
    ) {
        switch report {
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
#if DEBUG
            print("===>>> \(String(describing: self)): can't continue with status \(String(describing: state.status))")
#endif
            return
        }
        
        guard state.isValid else {
#if DEBUG
            print("===>>> \(String(describing: self)): can't continue with invalid transaction")
#endif
            return
        }
        
        state.context = stagePayment(state.context)
        
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
            case .connectivityError:
                state.status = .result(.failure(.updatePaymentFailure))
                
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
                state.status = .result(.failure(.transactionFailure))

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
        let updated = updatePayment(state.context, update)
        state.context = updated
        state.isValid = paymentInspector.validatePayment(updated)
        state.status = nil
    }
}
