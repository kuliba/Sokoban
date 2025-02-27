//
//  ContentReducer.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

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
            if !state.state.isLoading {
                let oldLanding = state.state.oldLanding
                state.state = .inflight(oldLanding)
                effect = .load
            }
                        
        case .dismissInformer:
            let oldLanding = state.state.oldLanding
            state.state = .loaded(oldLanding)
            
        case let .result(result):
            switch result {
            case let .failure(failure):
                switch failure.kind {
                case let .alert(message):
                    let oldLanding = state.state.oldLanding
                    state.state = .failure(.alert(message), oldLanding)
                    
                case let .informer(informer):
                    let oldLanding = state.state.oldLanding
                    state.state = .failure(.informer(informer), oldLanding)
                }

            case let .success(landing):
                state.state = .loaded(landing)
            }
        }
        
        return (state, effect)
    }
}

public extension ContentReducer {
    
    typealias State = SavingsAccountContentState<Landing, InformerPayload>
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
}
