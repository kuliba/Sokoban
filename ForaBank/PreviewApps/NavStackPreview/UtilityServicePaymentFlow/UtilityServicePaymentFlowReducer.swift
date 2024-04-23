//
//  UtilityServicePaymentFlowReducer.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

final class UtilityServicePaymentFlowReducer<Icon> {}

extension UtilityServicePaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .resetDestination:
            state.destination = nil
            
        case let .selectUtilityService(service):
            fatalError("what goes here???")
            
        case let .selectUtilityServiceOperator(`operator`):
            effect = .selectUtilityServiceOperator(`operator`)
        }
        
        return (state, effect)
    }
}

extension UtilityServicePaymentFlowReducer {
    
    typealias State = UtilityServicePaymentFlowState<Icon>
    typealias Event = UtilityServicePaymentFlowEvent<Icon>
    typealias Effect = UtilityServicePaymentFlowEffect<Icon>
}
