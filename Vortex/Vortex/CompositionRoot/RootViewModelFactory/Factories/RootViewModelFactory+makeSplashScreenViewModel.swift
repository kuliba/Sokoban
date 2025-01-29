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
            startPhaseOneTimer { dispatch(.start) }
            
        case .startPhaseTwoTimer:
            startPhaseTwoTimer { dispatch(.fadeOut) }
        }
    }
    
    typealias StartTimer = (@escaping () -> Void) -> Void
}

extension SplashScreenEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}

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
                state = state.zoomed()
                effect = .startPhaseOneTimer
            }
            
        case .fadeOut:
            if state.isNoSplash {
                state = state.splash()
                effect = .startPhaseTwoTimer

            }
            
        case .end:
            if state.isZoomed {
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

extension SplashScreenState {
    
    var isNoSplash: Bool {
        
        data.phase == .phaseTwo
    }
    
    var isSplash: Bool {
        
        data.phase == .phaseOne
    }
    
    var isZoomed: Bool {
        
        data.phase == .phaseTwo
    }

    func splash() -> Self {
        
        return .init(
            data: .init(
                phase: ??????,
                background: background,
                logo: logo,
                footer: footer,
                greeting: greeting,
                animation: animation
            ),
            config: config
        )
    }

    func zoomed() -> Self {
        
        return .init(
            data: .init(
                phase: ??????,
                background: background,
                logo: logo,
                footer: footer,
                greeting: greeting,
                animation: animation
            ),
            config: config
        )
    }

    func noSplash() -> Self {
        
        return .init(
            data: .init(
                phase: ??????,
                background: background,
                logo: logo,
                footer: footer,
                greeting: greeting,
                animation: animation
            ),
            config: config
        )
    }
}
