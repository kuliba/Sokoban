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
        ZoomDuration: Delay,
        FadeOutDuration: Delay
    ) -> SplashScreenViewModel {
        
        let reducer = SplashScreenReducer()
        let effectHandler = SplashScreenEffectHandler(
            startZoomTimer: { [weak self] completion in
                
                self?.schedulers.interactive.delay(for: ZoomDuration) {
                    
                    completion()
                }
            },
            startFadeOutTimer: { [weak self] completion in
                
                self?.schedulers.interactive.delay(for: FadeOutDuration) {
                    
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
        
        data.state == .zoomed
    }
    
    var isFadeOut: Bool {
        
        data.state == .fadedOut
    }
    
    var isNoSplash: Bool {
        
        data.state == .noSplash
    }
    
    func zoomed() -> Self {
        
        return .init(
            data: .init(
                state: .zoomed,
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

    func fadedOut() -> Self {
        
        return .init(
            data: .init(
                state: .fadedOut,
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
                state: .noSplash,
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
