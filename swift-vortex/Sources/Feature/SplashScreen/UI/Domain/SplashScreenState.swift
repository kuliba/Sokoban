//
//  SplashScreenState.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenState: Equatable {
    
    public var phase: Phase
    public let settings: Settings
    
    public init(
        phase: Phase,
        settings: Settings
    ) {
        self.phase = phase
        self.settings = settings
    }
}

extension SplashScreenState {
    
    public enum Phase: Equatable {
        
        case cover
        case warm
        case presented
        case hidden
    }
    
    public struct Settings: Equatable {
        
        public let image: Image
        public let bank: Logo
        public let name: Logo
        public let text: Text
        public let subtext: Text?
        
        public init(
            image: Image,
            bank: Logo,
            name: Logo,
            text: Text,
            subtext: Text?
        ) {
            self.image = image
            self.bank = bank
            self.name = name
            self.text = text
            self.subtext = subtext
        }
    }
}

extension SplashScreenState.Settings {
    
    public struct Logo: Equatable {
        
        public let color: Color
        public let shadow: Shadow
        
        public init(
            color: Color,
            shadow: Shadow
        ) {
            self.color = color
            self.shadow = shadow
        }
    }
    
    public struct Text: Equatable {
        
        public let color: Color
        public let size: CGFloat // TODO: ???
        public let value: String
        public let shadow: Shadow
        
        public init(
            color: Color,
            size: CGFloat,
            value: String,
            shadow: Shadow
        ) {
            self.color = color
            self.size = size
            self.value = value
            self.shadow = shadow
        }
    }
    
    public struct Shadow: Equatable {
        
        public let color: Color
        public let opacity: Double
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
        
        public init(
            color: Color,
            opacity: Double,
            radius: CGFloat,
            x: CGFloat,
            y: CGFloat
        ) {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.x = x
            self.y = y
        }
    }
}
