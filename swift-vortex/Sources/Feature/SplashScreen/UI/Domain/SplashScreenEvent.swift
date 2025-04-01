//
//  SplashScreenEvent.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

public enum SplashScreenEvent: Equatable {
    
    case prepare
    case start
    case hide
    case update(SplashScreenState.Settings?)
}
