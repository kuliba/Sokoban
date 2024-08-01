//
//  CardGuardianReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation

public final class CardGuardianReducer {
    
    public init() {}
}

public extension CardGuardianReducer {
 
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .appear:
            state.updateEvent(.appear)
            
        case let .buttonTapped(tap):
            switch tap {
                
            case let .toggleLock(card):
                state.updateEvent(.buttonTapped(.toggleLock(card)))
                
            case let .changePin(card):
                state.updateEvent(.buttonTapped(.changePin(card)))
                
            case let .toggleVisibilityOnMain(product):
                state.updateEvent(.buttonTapped(.toggleVisibilityOnMain(product)))
            }
        }
        return (state, .none)
    }
}

public extension CardGuardianReducer {
    
    typealias State = CardGuardianState
    typealias Event = CardGuardianEvent
    typealias Effect = CardGuardianEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
