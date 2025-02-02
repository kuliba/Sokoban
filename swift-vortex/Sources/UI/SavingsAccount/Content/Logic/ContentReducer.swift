//
//  ContentReducer.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public final class ContentReducer<Landing, InformerPayload> {
    
    let refreshRange: Range<CGFloat>
    let showTitleRange: PartialRangeFrom<CGFloat>

    public init(
        refreshRange: Range<CGFloat> = -100..<0,
        showTitleRange: PartialRangeFrom<CGFloat> = 100...
    ) {
        self.refreshRange = refreshRange
        self.showTitleRange = showTitleRange
    }
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
                        
        case let .offset(offset):
            if refreshRange.contains(offset), !state.status.isLoading {
                    let oldLanding = state.status.oldLanding
                    state.status = .inflight(oldLanding)
                    effect = .load
            }
            
            if offset > showTitleRange.lowerBound {
                if state.navTitle == .empty {
                    state.navTitle = .savingsAccount
                }
            }
            else if state.navTitle == .savingsAccount {
                state.navTitle = .empty
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
