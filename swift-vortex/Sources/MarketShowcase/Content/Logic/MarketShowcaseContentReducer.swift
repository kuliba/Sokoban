//
//  MarketShowcaseContentReducer.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public final class MarketShowcaseContentReducer<Landing, InformerPayload> {
    
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
                let oldLanding = state.status.oldLanding
                state.status = .inflight(oldLanding)
                effect = .load
            }
            
        case let .loaded(landing):
            state.status = .loaded(landing)
            
        case let .failure(failure):
            switch failure {
            case let .alert(message):
                let oldLanding = state.status.oldLanding
                state.status = .failure(.alert(message), oldLanding)
                
            case let .informer(informer):
                let oldLanding = state.status.oldLanding
                state.status = .failure(.informer(informer), oldLanding)
            }
            
        case let .selectLandingType(type):
            state.selection = .landingType(type)
            
        case .resetSelection:
            state.selection = nil
        }
        
        return (state, effect)
    }
}

public extension MarketShowcaseContentReducer {
    
    typealias State = MarketShowcaseContentState<Landing, InformerPayload>
    typealias Event = MarketShowcaseContentEvent<Landing, InformerPayload>
    typealias Effect = MarketShowcaseContentEffect
}
