//
//  SplashScreenReducer.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 29.01.2025.
//

import Foundation

final class SplashScreenReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .start:
            if state.isNoSplash {
                
                state = state.started()
                effect = .startFirstTimer
            }
            
        case .splash:
            if state.isStarted {

                state = state.splashed()
                effect = .startSecondTimer
            }
            
        case .noSplash:
            if state.isSplash {
                
                state = state.noSplash()
            }
        }
        
        return (state, effect)
    }
}

extension SplashScreenReducer {
    
    typealias State = SplashScreenState
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}
