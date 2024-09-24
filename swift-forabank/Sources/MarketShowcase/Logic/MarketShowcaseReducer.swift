//
//  MarketShowcaseReducer.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public final class MarketShowcaseReducer {
    
    private let alertLifespan: DispatchTimeInterval

    public init(alertLifespan: DispatchTimeInterval = .milliseconds(400)) {
        self.alertLifespan = alertLifespan
    }
}

public extension MarketShowcaseReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .update:
            if state != .inflight {
                state = .inflight
                effect = .load
            }
            
        case .loaded:
            state = .loaded
            
        case let .failure(kind):
            switch kind {
            case .timeout:
                state = .failure
                effect = .show(.informer)
            case .error:
                state = .failure
                effect = .show(.alert(alertLifespan))
            }
        }
        return (state, effect)
    }
}

public extension MarketShowcaseReducer {
    
    typealias Event = MarketShowcaseEvent
    typealias State = MarketShowcaseState
    typealias Effect = MarketShowcaseEffect
}
