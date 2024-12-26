//
//  AnywayPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class AnywayPaymentReducer<Payment, Response>
where Payment: AnywayPayment,
      Response: Equatable {
    
    private let update: Update
    
    public init(update: @escaping Update) {
        
        self.update = update
    }
}

public extension AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state, event) {
        case let (.payment(utilityPayment), _):
            (state, effect) = reduce(utilityPayment, event)
            
        case (.result, _):
            break
        }
        
        return (state, effect)
    }
}

public extension AnywayPaymentReducer {
    
    typealias Update = (inout Payment, Response) -> Void
    
    typealias State = AnywayPaymentState<Payment>
    typealias Event = AnywayPaymentEvent<Response>
    typealias Effect = AnywayPaymentEffect<Payment>
}

private extension AnywayPaymentReducer {
    
    func reduce(
        _ payment: Payment,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state: State = .payment(payment)
        var utilityPayment = payment
        var effect: Effect?
        
        switch event {
        case .continue:
            if utilityPayment.isFinalStep {
                if let verificationCode = utilityPayment.verificationCode {
                    utilityPayment.status = .inflight
                    state = .payment(utilityPayment)
                    effect = .makeTransfer(verificationCode)
                }
            } else {
                utilityPayment.status = .inflight
                state = .payment(utilityPayment)
                effect = .createAnywayTransfer(utilityPayment)
            }
            
        case let .fraud(fraudEvent):
            switch fraudEvent {
            case .cancelled:
                state = .result(.failure(.fraud(.cancelled)))
            case .expired:
                state = .result(.failure(.fraud(.expired)))
            }
            
        case let .receivedAnywayResult(anywayResult):
            switch anywayResult {
            case .failure(.connectivityError):
                state = .result(.failure(.transferError))
                
            case let .failure(.serverError(message)):
                state = .result(.failure(.serverError(message)))
                
            case let .success(response):
                update(&utilityPayment, response)
                utilityPayment.status = .none
                state = .payment(utilityPayment)
            }
            
        case let .receivedTransferResult(transferResult):
            state = .result(transferResult)
        }
        
        return (state, effect)
    }
}
