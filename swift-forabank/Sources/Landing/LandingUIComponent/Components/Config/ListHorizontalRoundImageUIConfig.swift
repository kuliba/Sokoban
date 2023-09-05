//
//  ListHorizontalRoundImageUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

public extension Landing.ListHorizontalRoundImage {
    
    struct Config: Equatable {
        
        public let backgroundColor: Color
        public let title: Title
        public let subtitle: Subtitle
        public let detail: Detail
        
        public struct Title: Equatable {
            
            public let color: Color
            public let font: Font
            
            public init(color: Color, font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        public struct Subtitle: Equatable {
            
            public let color: Color
            public let background: Color
            public let font: Font
            
            public init(color: Color, background: Color, font: Font) {
                self.color = color
                self.background = background
                self.font = font
            }
        }

        public struct Detail: Equatable {
            
            public let color: Color
            public let font: Font
            
            public init(color: Color, font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        public init(
            backgroundColor: Color,
            title: Title,
            subtitle: Subtitle,
            detail: Detail
        ) {
            self.backgroundColor = backgroundColor
            self.title = title
            self.subtitle = subtitle
            self.detail = detail
        }
    }
}
