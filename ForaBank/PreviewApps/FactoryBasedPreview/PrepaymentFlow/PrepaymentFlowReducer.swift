//
//  PrepaymentFlowReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PrepaymentFlowReducer {}

extension PrepaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .initiated(loaded):
            (state, effect) = reduce(state, loaded)
        }
        
        return (state, effect)
    }
}

extension PrepaymentFlowReducer {
    
    typealias State = PrepaymentFlowState
    typealias Event = PrepaymentFlowEvent
    typealias Effect = PrepaymentFlowEffect
}

private extension PrepaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event.Initiated
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

private extension PrepaymentFlowState.Destination.UtilityPrepaymentState {
    
    init(_ response: PrepaymentFlowEvent.Initiated.UtilityPaymentResponse) {
        
        self.init(
            lastPayments: response.lastPayments,
            operators: response.operators
        )
    }
}
