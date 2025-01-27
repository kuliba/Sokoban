//
//  SplashScreenConfig.swift
//
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI
import SharedConfigs

public struct SplashScreenDynamicConfig {

    let greeting: TextConfig
    let footer: TextConfig
    
    public init(greeting: TextConfig, footer: TextConfig) {
        self.greeting = greeting
        self.footer = footer
    }
}

public struct SplashScreenStaticConfig {

    let logoSize: CGSize
    let paddings: Paddings
//    let defaultBackground: Image
//    let defaultLogo: Image
    let spacing: CGFloat
    let scaleEffect: ScaleEffect
    
    public init(
        logoSize: CGSize,
        paddings: Paddings,
        spacing: CGFloat,
        scaleEffect: ScaleEffect
    ) {
        self.logoSize = logoSize
        self.paddings = paddings
        self.spacing = spacing
        self.scaleEffect = scaleEffect
    }
    
    public struct Paddings {
        
        let top: CGFloat
        let bottom: CGFloat
        
        public init(
            top: CGFloat,
            bottom: CGFloat
        ) {
            self.top = top
            self.bottom = bottom
        }
    }
    
    public struct ScaleEffect {
        
        let start: CGFloat
        let end: CGFloat
        
        public init(
            start: CGFloat,
            end: CGFloat
        ) {
            self.start = start
            self.end = end
        }
    }
}
