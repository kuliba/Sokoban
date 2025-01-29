//
//  SplashScreenEffectHandler.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 29.01.2025.
//

import Foundation

final class SplashScreenEffectHandler {
    
    let startPhaseOneTimer: StartTimer
    let startPhaseTwoTimer: StartTimer
    
    init(
        startPhaseOneTimer: @escaping StartTimer,
        startPhaseTwoTimer: @escaping StartTimer
    ) {
        self.startPhaseOneTimer = startPhaseOneTimer
        self.startPhaseTwoTimer = startPhaseTwoTimer
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .startPhaseOneTimer:
            dispatch(.fadeOut)
            
        case .startPhaseTwoTimer:
            startPhaseTwoTimer { dispatch(.noSplash) }
        }
    }
    
    typealias StartTimer = (@escaping () -> Void) -> Void
}

extension SplashScreenEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}
