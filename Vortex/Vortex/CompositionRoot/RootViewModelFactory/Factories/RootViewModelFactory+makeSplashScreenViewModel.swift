//
//  RootViewModelFactory+makeSplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreenUI
import SwiftUI

extension RootViewModelFactory {
    
    @inlinable
    func makeSplashScreenViewModel(
        flag: SplashScreenFlag
    ) -> SplashScreenViewModel {
        
        let initialState: SplashScreenState = flag.isActive ? .cover : .hidden
        let reducer = SplashScreenReducer()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: schedulers.main
        )
    }
}
