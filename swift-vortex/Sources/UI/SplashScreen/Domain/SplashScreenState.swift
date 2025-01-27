//
//  SplashScreenData.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI

public struct SplashScreenState {
    
    public var showSplash: Bool // ?? replace with phase1 & phase2

    public let background: Image
    public let logo: Image?
    public let footer: String?
    public let greeting: String?
    public let animation: Animation
    
    public init(
        showSplash: Bool,
        background: Image,
        logo: Image?,
        footer: String?,
        greeting: String?,
        animation: Animation
    ) {
        self.showSplash = showSplash
        self.background = background
        self.logo = logo
        self.footer = footer
        self.greeting = greeting
        self.animation = animation
    }
}
