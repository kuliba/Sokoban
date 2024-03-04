//
//  UtilityPaymentReducer.swift
//
//
//  Created by Igor Malyarov on 02.03.2024.
//

public final class UtilityPaymentReducer {
    
    public init() {}
}

public extension UtilityPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
               
        switch (state, event) {
            
        case var (.payment(utilityPayment), .continue):
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
            
        case let (.payment, .fraud(fraudEvent)):
            switch fraudEvent {
            case .cancelled:
                state = .result(.failure(.fraud(.cancelled)))
            case .expired:
                state = .result(.failure(.fraud(.expired)))
            }
            
        case (
            var .payment(utilityPayment),
            let .receivedAnywayResult(anywayResult)
        ):
            switch anywayResult {
            case .failure(.connectivityError):
                state = .result(.failure(.transferError))
                
            case let .failure(.serverError(message)):
                state = .result(.failure(.serverError(message)))
                
            case let .success(response):
                utilityPayment.status = .none
#warning("fix this update(utilityPayment, with: response) // protocol?")
                // update(utilityPayment, with: response)
                state = .payment(utilityPayment)
            }
            
        case let (.payment, .receivedTransferResult(transferResult)):
            state = .result(transferResult)
            
        case (.result, _):
            break
        }
        
        return (state, effect)
    }
}

public extension UtilityPaymentReducer {
    
    typealias PrePaymentReduce = (PrePaymentState, PrePaymentEvent) -> (PrePaymentState, PrePaymentEffect?)
    
    typealias State = UtilityPaymentState
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}
