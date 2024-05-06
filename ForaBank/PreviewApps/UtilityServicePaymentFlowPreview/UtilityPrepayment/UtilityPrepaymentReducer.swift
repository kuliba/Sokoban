//
//  UtilityPrepaymentReducer.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

final class UtilityPrepaymentReducer {}

extension UtilityPrepaymentReducer {
    
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

extension UtilityPrepaymentReducer {
    
    typealias State = UtilityPrepaymentState
    typealias Event = UtilityPrepaymentEvent
    typealias Effect = UtilityPrepaymentEffect
}
