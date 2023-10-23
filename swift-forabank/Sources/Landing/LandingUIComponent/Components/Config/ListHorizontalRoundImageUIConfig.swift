//
//  ListHorizontalRoundImageUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

public extension UILanding.List.HorizontalRoundImage {
    
    struct Config {
        
        public let backgroundColor: Color
        public let title: Title
        public let subtitle: Subtitle
        public let detail: Detail
        public let item: Item
        public let cornerRadius: CGFloat
        public let spacing: CGFloat
        public let height: CGFloat
        public let paddings: Paddings
        
        public struct Paddings {
            
            public let horizontal: CGFloat
            public let vertical: CGFloat
            public let vStackContentHorizontal: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat, vStackContentHorizontal: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
                self.vStackContentHorizontal = vStackContentHorizontal
            }
        }
        
        public struct Item {
            
            public let cornerRadius: CGFloat
            public let width: CGFloat
            public let spacing: CGFloat
            public let size: Size
            
            public struct Size {
                
                public let width: CGFloat
                public let height: CGFloat
                
                public init(width: CGFloat, height: CGFloat) {
                    self.width = width
                    self.height = height
                }
            }
            
            public init(
                cornerRadius: CGFloat,
                width: CGFloat,
                spacing: CGFloat,
                size: Size
            ) {
                self.cornerRadius = cornerRadius
                self.width = width
                self.spacing = spacing
                self.size = size
            }
        }

        public struct Title {
            
            public let color: Color
            public let font: Font
            
            public init(color: Color, font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        public struct Subtitle {
            
            public let color: Color
            public let background: Color
            public let font: Font
            public let cornerRadius: CGFloat
            public let padding: Padding
            
            public struct Padding {
                
                public let horizontal: CGFloat
                public let vertical: CGFloat
                
                public init(horizontal: CGFloat, vertical: CGFloat) {
                    self.horizontal = horizontal
                    self.vertical = vertical
                }
            }
            
            public init(
                color: Color,
                background: Color,
                font: Font,
                cornerRadius: CGFloat,
                padding: Padding
            ) {
                self.color = color
                self.background = background
                self.font = font
                self.cornerRadius = cornerRadius
                self.padding = padding
            }
        }

        public struct Detail {
            
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
            detail: Detail,
            item: Item,
            cornerRadius: CGFloat,
            spacing: CGFloat,
            height: CGFloat,
            paddings: Paddings
        ) {
            self.backgroundColor = backgroundColor
            self.title = title
            self.subtitle = subtitle
            self.detail = detail
            self.item = item
            self.cornerRadius = cornerRadius
            self.spacing = spacing
            self.height = height
            self.paddings = paddings
        }
    }
}
