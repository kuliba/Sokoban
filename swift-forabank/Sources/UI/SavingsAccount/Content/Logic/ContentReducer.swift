//
//  ContentReducer.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

public final class ContentReducer<Landing, InformerPayload> {
    
    public init() {}
}

public extension ContentReducer {
    
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
            
        case .selectOrder:
            state.selection = .order
            
        case .resetSelection:
            state.selection = nil
        }
        
        return (state, effect)
    }
}

public extension ContentReducer {
    
    typealias State = SavingsAccountContentState<Landing, InformerPayload>
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
}
