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
        
        public let link: String?
        public let viewDuration: Int?
        public let hasAnimation: Bool
        public let bankLogo: Logo?
        public let text: Text?
        public let background: Background?
        public let subtext: Text?
        public let bankName: Logo?
        
        public init(
            link: String?,
            viewDuration: Int?,
            hasAnimation: Bool,
            bankLogo: Logo?,
            text: Text?,
            background: Background?,
            subtext: Text?,
            bankName: Logo?
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
        
        public let color: String?
        public let shadow: Shadow?
        
        public init(
            color: String? = nil,
            shadow: Shadow? = nil
        ) {
            self.color = color
            self.shadow = shadow
        }
    }
    
    public struct Text: Equatable {
        
        public let color: String?
        public let size: Int?
        public let value: String?
        public let shadow: Shadow?
        
        public init(
            color: String? = nil,
            size: Int? = nil,
            value: String? = nil,
            shadow: Shadow?
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
        public let opacity: Int?
        
        public init(
            hasBackground: Bool,
            color: String? = nil,
            opacity: Int? = nil
        ) {
            self.hasBackground = hasBackground
            self.color = color
            self.opacity = opacity
        }
    }
    
    public struct Shadow: Equatable {
        
        public let x: Int?
        public let y: Int?
        public let blur: Int?
        public let color: String?
        public let opacity: Int?
        
        public init(
            x: Int?,
            y: Int?,
            blur: Int?,
            color: String?,
            opacity: Int?
        ) {
            self.x = x
            self.y = y
            self.blur = blur
            self.color = color
            self.opacity = opacity
        }
    }
}
