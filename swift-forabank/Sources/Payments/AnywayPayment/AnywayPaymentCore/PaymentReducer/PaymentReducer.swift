//
//  PaymentReducer.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public final class PaymentReducer<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Payment, Update> {
    
    private let checkFraud: CheckFraud
    private let getVerificationCode: GetVerificationCode
    private let makeDigest: MakeDigest
    private let parameterReduce: ParameterReduce
    private let updatePayment: UpdatePayment
    private let validatePayment: ValidatePayment
    
    public init(
        checkFraud: @escaping CheckFraud,
        getVerificationCode: @escaping GetVerificationCode,
        makeDigest: @escaping MakeDigest,
        parameterReduce: @escaping ParameterReduce,
        updatePayment: @escaping UpdatePayment,
        validatePayment: @escaping ValidatePayment
    ) {
        self.checkFraud = checkFraud
        self.getVerificationCode = getVerificationCode
        self.makeDigest = makeDigest
        self.parameterReduce = parameterReduce
        self.updatePayment = updatePayment
        self.validatePayment = validatePayment
    }
}

public extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state.status, event) {
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
            
        case let (_, .parameter(parameterEvent)):
            reduce(&state, &effect, with: parameterEvent)
            
        case let (_, .update(updateResult)):
            reduce(&state, with: updateResult)
            
        default:
            break
        }
        
        return (state, effect)
    }
}

public extension PaymentReducer {
    
    typealias CheckFraud = (Payment) -> Bool
    typealias MakeDigest = (Payment) -> Digest
    typealias ParameterReduce = (Payment, ParameterEvent) -> (Payment, Effect?)
    typealias UpdatePayment = (Payment, Update) -> Payment
    
    typealias ValidatePayment = (Payment) -> Bool
    typealias GetVerificationCode = (Payment) -> VerificationCode?
    
    typealias State = PaymentState<Payment, DocumentStatus, OperationDetails>
    typealias Event = PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update>
    typealias Effect = PaymentEffect<Digest, ParameterEffect>
}

private extension PaymentReducer {
    
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
        with event: ParameterEvent
    ) {
        let payment: Payment
        (payment, effect) = parameterReduce(state.payment, event)
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
        with updateResult: Event.UpdateResult
    ) {
        switch updateResult {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                state.status = .result(.failure(.updateFailure))
                
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
