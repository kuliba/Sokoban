//
//  SplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreen

typealias SplashScreenViewModel = RxViewModel<SplashScreenState, SplashScreenEvent, SplashScreenEffect>

typealias SplashScreenState = SplashScreen.Splash

enum SplashScreenEvent {
    
    case start
    case fadeOut
    case noSplash
}

enum SplashScreenEffect {
    
    case startPhaseOneTimer
    case startPhaseTwoTimer
}
