//
//  SplashScreenEffectHandler.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 29.01.2025.
//

import Foundation

final class SplashScreenEffectHandler {
    
    let startFirstTimer: StartTimer
    let startSecondTimer: StartTimer
    
    init(
        startFirstTimer: @escaping StartTimer,
        startSecondTimer: @escaping StartTimer
    ) {
        self.startFirstTimer = startFirstTimer
        self.startSecondTimer = startSecondTimer
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .startFirstTimer:
            dispatch(.splash)
            
        case .startSecondTimer:
            startSecondTimer { dispatch(.noSplash) }
        }
    }
    
    typealias StartTimer = (@escaping () -> Void) -> Void
}

extension SplashScreenEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}
