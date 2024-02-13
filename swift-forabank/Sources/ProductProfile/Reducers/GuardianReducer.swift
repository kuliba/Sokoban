//
//  GuardianReducer.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

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
        case .blockCard:
            state = blockCard(state)
        case .unblockCard:
            state = unblockCard(state)
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
        _ state: State
    ) -> State {
                
        var state = state
        state.status = .blockCard
        
        return state
    }
    
    func unblockCard(
        _ state: State
    ) -> State {
                
        var state = state
        state.status = .unblockCard
        
        return state
    }
}
