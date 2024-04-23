//
//  UtilityServicePaymentFlowReducer.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

final class UtilityServicePaymentFlowReducer {}

extension UtilityServicePaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .resetDestination:
            state = nil
        }
        
        return (state, effect)
    }
}

extension UtilityServicePaymentFlowReducer {
    
    typealias State = UtilityServicePaymentFlowState
    typealias Event = UtilityServicePaymentFlowEvent
    typealias Effect = UtilityServicePaymentFlowEffect
}
