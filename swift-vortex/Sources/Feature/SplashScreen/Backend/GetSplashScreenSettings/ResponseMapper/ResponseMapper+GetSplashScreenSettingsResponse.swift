//
//  ResponseMapper+GetSplashScreenSettingsResponse.swift
//
//
//  Created by Nikolay Pochekuev on 19.02.2025.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public typealias GetSplashScreenSettingsResponse = SerialStamped<String, SplashScreenSettings>
    
    public struct SplashScreenSettings: Equatable {
        
        public let link: String
        public let viewDuration: Int?
        public let hasAnimation: Bool
        public let bankLogo: Logo
        public let text: Text
        public let background: Background?
        public let subtext: Text?
        public let bankName: Logo
        
        public init(
            link: String,
            viewDuration: Int?,
            hasAnimation: Bool,
            bankLogo: Logo,
            text: Text,
            background: Background?,
            subtext: Text?,
            bankName: Logo
        ) {
            self.link = link
            self.viewDuration = viewDuration
            self.hasAnimation = hasAnimation
            self.bankLogo = bankLogo
            self.text = text
            self.background = background
            self.subtext = subtext
            self.bankName = bankName
        }
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
        public let size: Double
        public let value: String
        public let shadow: Shadow
        
        public init(
            color: String,
            size: Double,
            value: String,
            shadow: Shadow
        ) {
            self.color = color
            self.size = size
            self.value = value
            self.shadow = shadow
        }
    }
    
    public struct Background: Equatable {
        
        public let hasBackground: Bool
        public let color: String?
        public let opacity: Double?
        
        public init(
            hasBackground: Bool,
            color: String? = nil,
            opacity: Double? = nil
        ) {
            self.hasBackground = hasBackground
            self.color = color
            self.opacity = opacity
        }
    }
    
    public struct Shadow: Equatable {
        
        public let x: Double
        public let y: Double
        public let blur: Double
        public let color: String
        public let opacity: Double
        
        public init(
            x: Double,
            y: Double,
            blur: Double,
            color: String,
            opacity: Double
        ) {
            self.x = x
            self.y = y
            self.blur = blur
            self.color = color
            self.opacity = opacity
        }
    }
}
