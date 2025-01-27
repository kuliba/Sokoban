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
        initialState: SplashScreenState
    ) -> SplashScreenViewModel {
        
        return .init(
            initialState: initialState,
            reduce: { state, event in
                
                var state = state
                switch event {
                case .start:
                    state.data.showSplash = true
                }
                
                return (state, nil)
            },
            handleEffect: { _,_ in },
            scheduler: schedulers.main
        )
    }
}
