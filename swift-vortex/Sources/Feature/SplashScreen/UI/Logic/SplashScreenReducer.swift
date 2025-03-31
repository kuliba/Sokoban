//
//  SplashScreenReducer.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

public final class SplashScreenReducer {
    
    public init() {}
}

public extension SplashScreenReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        let effect: Effect? = nil
        
        switch event {
        case .hide:
            state.phase = .hidden
            
        case .prepare:
            state.phase = .warm
            
        case .start:
            state.phase = .presented
            
        case let .update(settings):
            state.settings = settings
        }
        
        return (state, effect)
    }
}

public extension SplashScreenReducer {
    
    typealias State = SplashScreenState
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}
