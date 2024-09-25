//
//  MarketShowcaseReducer.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public final class MarketShowcaseReducer {
    
    private let alertLifespan: DispatchTimeInterval
    private let goToMain: () -> Void

    public init(
        alertLifespan: DispatchTimeInterval = .milliseconds(400),
        goToMain: @escaping () -> Void
    ) {
        self.alertLifespan = alertLifespan
        self.goToMain = goToMain
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
            if state.status != .inflight {
                state.status = .inflight
                effect = .load
            }
            
        case .loaded:
            state.status = .loaded
            
        case let .failure(kind):
            switch kind {
            case .timeout:
                state.status = .failure
                effect = .show(.informer)
            case .error:
                state.status = .failure
                effect = .show(.alert(alertLifespan))
            }
        case .showAlert:
            state.alert = .init(message: "Попробуйте позже")
            
        case .goToMain:
            state.alert = nil
            goToMain()
        }
        return (state, effect)
    }
}

public extension MarketShowcaseReducer {
    
    typealias Event = MarketShowcaseEvent
    typealias State = MarketShowcaseState
    typealias Effect = MarketShowcaseEffect
}
