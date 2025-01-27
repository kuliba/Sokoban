//
//  SplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreen

typealias SplashScreenViewModel = RxViewModel<SplashScreenState, SplashScreenEvent, Never>

typealias SplashScreenState = SplashScreen.Splash

enum SplashScreenEvent {
    
    case start // TODO: add`end` event to finish animation
}

typealias SplashScreenEffect = Never
