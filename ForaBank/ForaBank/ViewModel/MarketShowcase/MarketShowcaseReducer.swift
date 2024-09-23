//
//  MarketShowcaseReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 23.09.2024.
//

import Foundation

final class MarketShowcaseReducer {
    
    init() {}
}

extension MarketShowcaseReducer {
    
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

extension MarketShowcaseReducer {
    
    typealias Event = MarketShowcaseEvent
    typealias State = MarketShowcaseState
    typealias Effect = MarketShowcaseEffect
}
