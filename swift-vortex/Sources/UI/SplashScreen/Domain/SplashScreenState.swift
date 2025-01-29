//
//  SplashScreenData.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI

public struct SplashScreenState {
    
    public enum SplashScreenPhase {
        case zoom
        case fadeOut
        case noSplash
    }
    
    public var phase: SplashScreenPhase
    
    public let background: Image
    public let logo: Image?
    public let footer: String?
    public let greeting: String?
    public let message: String?
    public let animation: Animation
    
    public init(
        phase: SplashScreenPhase,
        background: Image,
        logo: Image?,
        footer: String?,
        greeting: String?,
        message: String?,
        animation: Animation
    ) {
        self.phase = phase
        self.background = background
        self.logo = logo
        self.footer = footer
        self.greeting = greeting
        self.message = message
        self.animation = animation
    }
}
