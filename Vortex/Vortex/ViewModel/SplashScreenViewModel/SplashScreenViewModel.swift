//
//  SplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreenUI

typealias SplashScreenViewModel = RxViewModel<SplashScreenState, SplashScreenEvent, SplashScreenEffect>

typealias SplashScreenState = SplashScreenUI.Splash

enum SplashScreenEvent {
    
    case start
    case splash
    case noSplash
}

enum SplashScreenEffect {
    
    case startFirstTimer
    case startSecondTimer
}
