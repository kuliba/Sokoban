//
//  SplashScreenEffectHandler.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 29.01.2025.
//

import Foundation

final class SplashScreenEffectHandler {
    
    let startZoomTimer: StartTimer
    let startFadeOutTimer: StartTimer
    
    init(
        startZoomTimer: @escaping StartTimer,
        startFadeOutTimer: @escaping StartTimer
    ) {
        self.startZoomTimer = startZoomTimer
        self.startFadeOutTimer = startFadeOutTimer
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .startZoomTimer:
            dispatch(.fadeOut)
            
        case .startFadeOutTimer:
            startFadeOutTimer { dispatch(.noSplash) }
        }
    }
    
    typealias StartTimer = (@escaping () -> Void) -> Void
}

extension SplashScreenEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}
