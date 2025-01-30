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
            startFirstTimer: { [weak self] completion in
                
                self?.schedulers.interactive.delay(for: phaseOneDuration) {
                    
                    completion()
                }
            },
            startSecondTimer: { [weak self] completion in
                
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
