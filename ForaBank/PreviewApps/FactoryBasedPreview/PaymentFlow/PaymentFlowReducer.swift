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
}
