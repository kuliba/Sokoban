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
                
                effect = .startPhaseOneTimer
                state = state.zoomed()
            }
            
        case .fadeOut:
            if state.isZoomed {

                effect = .startPhaseTwoTimer
                state = state.fadeOut()
            }
            
        case .noSplash:
            if state.isFadeOut {
                
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
