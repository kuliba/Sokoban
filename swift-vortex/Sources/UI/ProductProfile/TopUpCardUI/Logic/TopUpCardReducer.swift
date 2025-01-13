//
//  TopUpCardReducer.swift
//  
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Foundation

public final class TopUpCardReducer {
    
    public init() {}
}

public extension TopUpCardReducer {
 
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
                
            case let .accountAnotherBank(card):
                state.updateEvent(.buttonTapped(.accountAnotherBank(card)))
                
            case let .accountOurBank(card):
                state.updateEvent(.buttonTapped(.accountOurBank(card)))
            }
        }
        return (state, .none)
    }
}

public extension TopUpCardReducer {
    
    typealias State = TopUpCardState
    typealias Event = TopUpCardEvent
    typealias Effect = TopUpCardEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
