//
//  PaymentReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentReducer {}

extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .utilityService(utilityServiceEvent):
            (state, effect) = reduce(state, utilityServiceEvent)
        }
        
        return (state, effect)
    }
}

extension PaymentReducer {
    
    typealias State = PaymentState
    typealias Event = PaymentEvent
    typealias Effect = PaymentEffect
}

#warning("extract to utilityServicePaymentReduce")
private extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: UtilityServicePaymentEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .initiated(initiated):
            (state, effect) = reduce(state, initiated)
            
        case let .prepayment(prepaymentEvent):
            (state, effect) = reduce(state, prepaymentEvent)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: UtilityServicePaymentEvent.InitiateResponse
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        fatalError("unimplemented")
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: UtilityServicePrepaymentEvent
    ) -> (State, Effect?) {
        
        fatalError("delegate to UtilityPrepaymentPickerEventReduce?")
    }
}

//private extension UtilityServicePaymentState {
//
//    init(_ response: String) {
//
//        self.init(
//            lastPayments: response.lastPayments,
//            operators: response.operators
//        )
//    }
//}
