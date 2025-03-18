//
//  SplashScreenSettings.swift
//
//
//  Created by Igor Malyarov on 18.03.2025.
//

import Foundation
import VortexTools

public struct SplashScreenSettings: Equatable {
    
    public let duration: TimeInterval
    public let logo: Logo
    public let text: Text
    public let subtext: Text?
    public let footer: Logo
    
    public let imageData: Result<Data, DataFailure>?
    public let link: String
    public let period: String
    
    public init(
        duration: TimeInterval,
        logo: Logo,
        text: Text,
        subtext: Text?,
        footer: Logo,
        imageData: Result<Data, DataFailure>?,
        link: String,
        period: String
    ) {
        self.duration = duration
        self.logo = logo
        self.text = text
        self.subtext = subtext
        self.footer = footer
        self.imageData = imageData
        self.link = link
        self.period = period
    }
}

extension SplashScreenSettings {
    
    public struct DataFailure: Error, Equatable {
        
        public init() {}
    }
    
    public struct Logo: Equatable {
        
        public let color: String
        public let shadow: Shadow
        
        public init(
            color: String,
            shadow: Shadow
        ) {
            self.color = color
            self.shadow = shadow
        }
    }
    
    public struct Text: Equatable {
        
        public let color: String
        public let size: CGFloat
        public let value: String
        public let shadow: Shadow
        
        public init(
            color: String,
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
        
        public let color: String
        public let opacity: Double
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
        
        public init(
            color: String,
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

extension SplashScreenSettings: Categorized {
    
    public var category: String {
        period
    }
}
