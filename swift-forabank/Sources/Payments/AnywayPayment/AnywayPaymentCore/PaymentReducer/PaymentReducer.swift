//
//  PaymentReducer.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public final class PaymentReducer<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Payment, Update> {
    
    private let parameterReduce: AdaptedParameterReduce
    private let adaptedUpdatePayment: AdaptedUpdatePayment
    
    public init(
        checkFraud: @escaping CheckFraud,
        parameterReduce: @escaping ParameterReduce,
        updatePayment: @escaping UpdatePayment,
        validatePayment: @escaping ValidatePayment
    ) {
        self.parameterReduce = {
            
            let (payment, effect) = parameterReduce($0, $1)
            return (payment, effect, validatePayment(payment))
        }
        self.adaptedUpdatePayment = {
            
            let updated = updatePayment($0, $1)
            return (updated, validatePayment(updated), checkFraud($1) ? .fraudSuspected : nil)
        }
    }
}

public extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .completePayment(transactionResult):
            reduce(&state, with: transactionResult)
            
        case let .parameter(parameterEvent):
            reduce(&state, &effect, with: parameterEvent)
            
        case let .update(updateResult):
            reduce(&state, with: updateResult)
        }
        
        return (state, effect)
    }
}

public extension PaymentReducer {
    
    typealias CheckFraud = (Update) -> Bool
    typealias ParameterReduce = (Payment, ParameterEvent) -> (Payment, Effect?)
    typealias UpdatePayment = (Payment, Update) -> Payment
    
    typealias ValidatePayment = (Payment) -> Bool
    
    typealias State = PaymentState<Payment, DocumentStatus, OperationDetails>
    typealias Event = PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update>
    typealias Effect = PaymentEffect<Digest, ParameterEffect>
}

private extension PaymentReducer {
    
    typealias AdaptedParameterReduce = (Payment, ParameterEvent) -> (Payment, Effect?, Bool)
    typealias AdaptedUpdatePayment = (Payment, Update) -> (Payment, Bool, State.Status?)
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
        with event: ParameterEvent
    ) {
        (state.payment, effect, state.isValid) = parameterReduce(state.payment, event)
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
            (state.payment, state.isValid, state.status) = adaptedUpdatePayment(state.payment, update)
        }
    }
}
