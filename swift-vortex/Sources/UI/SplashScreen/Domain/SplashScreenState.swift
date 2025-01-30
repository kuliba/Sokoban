//
//  SplashScreenData.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI

public struct SplashScreenState {
    
    public enum SplashState {
        case start
        case splash
        case noSplash
    }
    
    public var state: SplashState
    
    public let background: Image
    public let logo: Image?
    public let footer: String?
    public let greeting: String?
    public let message: String?
    public let animation: Animation
    
    public init(
        state: SplashState,
        background: Image,
        logo: Image?,
        footer: String?,
        greeting: String?,
        message: String?,
        animation: Animation
    ) {
        self.state = state
        self.background = background
        self.logo = logo
        self.footer = footer
        self.greeting = greeting
        self.message = message
        self.animation = animation
    }
}
