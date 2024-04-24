//
//  PaymentsReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class PaymentsReducer {}

extension PaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .buttonTapped(buttonTapped):
            (state, effect) = reduce(state, buttonTapped)
            
        case .dismissDestination:
            state.destination = nil
        }
        
        return (state, effect)
    }
}

extension PaymentsReducer {
    
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
}

private extension PaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event.ButtonTapped
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .utilityService:
            effect = .initiateUtilityPayment
        }
        
        return (state, effect)
    }
}
