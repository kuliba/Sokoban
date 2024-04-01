//
//  TransactionReducer.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public final class TransactionReducer<DocumentStatus, OperationDetails, Payment, PaymentEffect, PaymentEvent, PaymentDigest, PaymentUpdate> {
    
    private let checkFraud: CheckFraud
    private let getVerificationCode: GetVerificationCode
    private let makeDigest: MakeDigest
    private let paymentReduce: PaymentReduce
    private let updatePayment: UpdatePayment
    private let validatePayment: ValidatePayment
    
    public init(
        checkFraud: @escaping CheckFraud,
        getVerificationCode: @escaping GetVerificationCode,
        makeDigest: @escaping MakeDigest,
        paymentReduce: @escaping PaymentReduce,
        updatePayment: @escaping UpdatePayment,
        validatePayment: @escaping ValidatePayment
    ) {
        self.checkFraud = checkFraud
        self.getVerificationCode = getVerificationCode
        self.makeDigest = makeDigest
        self.paymentReduce = paymentReduce
        self.updatePayment = updatePayment
        self.validatePayment = validatePayment
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
            switch state.status {
            case .serverError:
                state.status = nil
                
            default:
                break
            }
            
        case (.fraudSuspected, _):
            switch event {
            case let .fraud(fraudEvent):
                reduce(&state, &effect, with: fraudEvent)
                
            default:
                break
            }
            
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
    
    typealias CheckFraud = (Payment) -> Bool
    typealias MakeDigest = (Payment) -> PaymentDigest
    typealias PaymentReduce = (Payment, PaymentEvent) -> (Payment, Effect?)
    typealias UpdatePayment = (Payment, PaymentUpdate) -> Payment
    
    typealias ValidatePayment = (Payment) -> Bool
    typealias GetVerificationCode = (Payment) -> VerificationCode?
    
    typealias State = Transaction<DocumentStatus, OperationDetails, Payment>
    typealias Event = TransactionEvent<DocumentStatus, OperationDetails, PaymentEvent, PaymentUpdate>
    typealias Effect = TransactionEffect<PaymentDigest, PaymentEffect>
}

private extension TransactionReducer {
    
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
        _ effect: inout Effect?,
        with event: PaymentEvent
    ) {
        let payment: Payment
        (payment, effect) = paymentReduce(state.payment, event)
        state.payment = payment
        state.isValid = validatePayment(payment)
    }
    
    func reduceContinue(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard state.isValid, state.status == nil else { return }
        
        if let verificationCode = getVerificationCode(state.payment) {
             effect = .makePayment(verificationCode)
        } else {
            effect = .continue(makeDigest(state.payment))
        }
    }
    
    func initiatePayment(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard state.status == nil else { return }
    
        effect = .initiatePayment(makeDigest(state.payment))
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
            state.isValid = validatePayment(updated)
            state.status = checkFraud(updated) ? .fraudSuspected : nil
        }
    }
}
