//
//  MarketShowcaseContentReducer.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public final class MarketShowcaseContentReducer<Landing> {
    
    public init() {}
}

public extension MarketShowcaseContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        case .load:
            
            if !state.status.isLoading {
                state.status = .inflight
                effect = .load
            }
            
        case let .loaded(landing):
            state.status = .loaded(landing)
            
        case .loadFailure:
            state.status = .failure
            
        case let .selectLandingType(type):
            state.selection = .landingType(type)
            
        case .resetSelection:
            state.selection = nil
        }
        
        return (state, effect)
    }
}

public extension MarketShowcaseContentReducer {
    
    typealias State = MarketShowcaseContentState<Landing>
    typealias Event = MarketShowcaseContentEvent<Landing>
    typealias Effect = MarketShowcaseContentEffect
}
