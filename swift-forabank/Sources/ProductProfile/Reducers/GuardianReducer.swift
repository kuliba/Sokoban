//
//  GuardianReducer.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import CardGuardianModule

public final class GuardianReducer {
    
    public init() {}
}

public extension GuardianReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .blockCard(card):
            (state, effect) = blockCard(state, card)
        case let .unblockCard(card):
            (state, effect) = unblockCard(state, card)
        }
        
        return (state, effect)
    }
}

public extension GuardianReducer {
    
    typealias State = ProductProfileState
    typealias Event = GuardianEvent
    typealias Effect = ProductProfileEffect
}

private extension GuardianReducer {
    
    func blockCard(
        _ state: State,
        _ card: Card
    ) -> (State, Effect?) {
                
        var state = state
        var effect: Effect?
        
        state.status = .infligth
        effect = .blockCard(card)
        
        return (state, effect)
    }
    
    func unblockCard(
        _ state: State,
        _ card: Card
    ) -> (State, Effect?) {

        var state = state
        var effect: Effect?
        
        state.status = .infligth
        effect = .unblockCard(card)
        
        return (state, effect)
    }
}
