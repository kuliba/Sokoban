//
//  PaymentReducer.swift
//
//
//  Created by Igor Malyarov on 30.03.2024.
//

public final class PaymentReducer<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Payment, Update> {
    
    private let parameterReduce: ParameterReduce
    private let updatePayment: UpdatePayment
    
    public init(
        parameterReduce: @escaping ParameterReduce,
        updatePayment: @escaping UpdatePayment
    ) {
        self.parameterReduce = parameterReduce
        self.updatePayment = updatePayment
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
    
    typealias ParameterReduce = (Payment, ParameterEvent) -> (Payment, Effect?)
    typealias UpdatePayment = (Payment, Update) -> Payment
    
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
        with event: ParameterEvent
    ) {
        let (payment, e) = parameterReduce(state.payment, event)
        state.payment = payment
        effect = e
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
            state.payment = updatePayment(state.payment, update)
        }
    }
}
