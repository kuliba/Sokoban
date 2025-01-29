//
//  RootViewModelFactory+makeSplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreen
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func makeSplashScreenViewModel(
        initialState: SplashScreenState,
        phaseOneDuration: Delay,
        phaseTwoDuration: Delay
    ) -> SplashScreenViewModel {
        
        let reducer = SplashScreenReducer()
        let effectHandler = SplashScreenEffectHandler(
            startPhaseOneTimer: { [weak self] completion in
                
                self?.schedulers.interactive.delay(for: phaseOneDuration) {
                    
                    completion()
                }
            },
            startPhaseTwoTimer: { [weak self] completion in
                
                self?.schedulers.interactive.delay(for: phaseTwoDuration) {
                    
                    completion()
                }
            }
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
}

extension SplashScreenState {
    
    var isZoomed: Bool {
        
        data.phase == .zoom
    }
    
    var isFadeOut: Bool {
        
        data.phase == .fadeOut
    }
    
    var isNoSplash: Bool {
        
        data.phase == .noSplash
    }
    
    func zoomed() -> Self {
        
        return .init(
            data: .init(
                phase: .zoom,
                background: data.background,
                logo: data.logo,
                footer: data.footer,
                greeting: data.greeting,
                message: data.message,
                animation: data.animation
            ),
            config: config
        )
    }

    func fadeOut() -> Self {
        
        return .init(
            data: .init(
                phase: .fadeOut,
                background: data.background,
                logo: data.logo,
                footer: data.footer,
                greeting: data.greeting,
                message: data.message,
                animation: data.animation
            ),
            config: config
        )
    }

    func noSplash() -> Self {
        
        return .init(
            data: .init(
                phase: .noSplash,
                background: data.background,
                logo: data.logo,
                footer: data.footer,
                greeting: data.greeting, 
                message: data.message,
                animation: data.animation
            ),
            config: config
        )
    }
}
