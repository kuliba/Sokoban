//
//  RootViewModelFactory+makeSplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreen

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
            startPhaseOneTimer { dispatch(.phaseOne) }
            
        case .startPhaseTwoTimer:
            startPhaseTwoTimer { dispatch(.phaseTwo) }
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
                state = state.splash()
                effect = .startPhaseOneTimer
            }
            
        case .phaseOne:
            if state.isSplash {
                state = state.zoomed()
                effect = .startPhaseTwoTimer
            }
            
        case .phaseTwo:
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
        
        // TODO: ????
    }
    
    var isSplash: Bool {
        
        // TODO: ????
    }
    
    var isZoomed: Bool {
        
        // TODO: ????
    }
    
    func splash() -> Self {
        
        // TODO: ????
    }
    
    func zoomed() -> Self {
        
        // TODO: ????
    }
    
    func noSplash() -> Self {
        
        // TODO: ????
    }
}
