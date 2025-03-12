//
//  SplashScreenViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.01.2025.
//

import RxViewModel
import SplashScreenUI

typealias SplashScreenViewModel = RxViewModel<SplashScreenState, SplashScreenEvent, SplashScreenEffect>

enum SplashScreenState {
    
    case cover
    case warm
    case presented
    case hidden
}

enum SplashScreenEvent {
    
    case prepare
    case start
    case hide
}

enum SplashScreenEffect {}
