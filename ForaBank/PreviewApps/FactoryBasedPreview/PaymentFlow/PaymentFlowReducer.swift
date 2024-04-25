//
//  PaymentFlowReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentFlowReducer {}

extension PaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .loaded(loaded):
            (state, effect) = reduce(state, loaded)
        }
        
        return (state, effect)
    }
}

extension PaymentFlowReducer {
    
    typealias State = PaymentFlowState
    typealias Event = PaymentFlowEvent
    typealias Effect = PaymentFlowEffect
}

private extension PaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event.Loaded
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .utilityPayment(response):
            state.destination = .utilityServicePayment(.init(response))
        }
        
        return (state, effect)
    }
}

private extension PaymentFlowState.Destination.UtilityPrepaymentState {
    
    init(_ response: PaymentFlowEvent.Loaded.UtilityPaymentResponse) {
        
        self.init(
            lastPayments: response.lastPayments,
            operators: response.operators
        )
    }
}
