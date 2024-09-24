//
//  MarketShowcaseReducer.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public final class MarketShowcaseReducer {
    
    private let makeInformer: (String) -> Void

    public init(makeInformer: @escaping (String) -> Void) {
        self.makeInformer = makeInformer
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
        }
        return (state, effect)
    }
}

public extension MarketShowcaseReducer {
    
    typealias Event = MarketShowcaseEvent
    typealias State = MarketShowcaseState
    typealias Effect = MarketShowcaseEffect
}
