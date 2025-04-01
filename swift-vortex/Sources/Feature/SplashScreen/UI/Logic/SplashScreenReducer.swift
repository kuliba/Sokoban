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
        var effect: Effect?
        
        switch event {
        case .hide:
            state.phase = .hidden
            effect = .requestUpdate
            
        case .prepare:
            state.phase = .warm
            
        case .start:
            state.phase = .presented
            
        case .update(nil):
            // silent failure
            break
            
        case let .update(.some(settings)):
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
