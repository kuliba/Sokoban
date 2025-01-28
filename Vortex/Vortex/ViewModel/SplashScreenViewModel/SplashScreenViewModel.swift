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
    
    case start // TODO: add`end` event to finish animation
    case phaseOne // TODO: - rename to reflect phase
    case phaseTwo
}

enum SplashScreenEffect {
    
    case startPhaseOneTimer
    case startPhaseTwoTimer
}

/*
 
 State:
 - no splash
 - splash
 - zoomed splash
 
 Lifecycle: // reduce
 - no splash
 == `start` event =>
 - splash + start timer (= effect!!)
 == timer: // phase1 // zoomed
 - splash = zoomed + start 2nd timer (= effect!!)
 == 2nd timer: // phase2
 - state = no splash + NO effect
 
 */
