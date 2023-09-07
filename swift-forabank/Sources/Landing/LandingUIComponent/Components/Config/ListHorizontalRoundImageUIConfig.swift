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
        public let item: Item
        public let cornerRadius: CGFloat
        public let spacing: CGFloat
        public let height: CGFloat
        
        public struct Item: Equatable {
            
            public let cornerRadius: CGFloat
            public let width: CGFloat
            public let spacing: CGFloat
            
            public init(cornerRadius: CGFloat, width: CGFloat, spacing: CGFloat) {
                self.cornerRadius = cornerRadius
                self.width = width
                self.spacing = spacing
            }
        }

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
            public let cornerRadius: CGFloat
            public let padding: Padding
            
            public struct Padding: Equatable {
                
                public let horizontal: CGFloat
                public let vertical: CGFloat
                
                public init(horizontal: CGFloat, vertical: CGFloat) {
                    self.horizontal = horizontal
                    self.vertical = vertical
                }
            }
            
            public init(color: Color, background: Color, font: Font, cornerRadius: CGFloat, padding: Padding) {
                self.color = color
                self.background = background
                self.font = font
                self.cornerRadius = cornerRadius
                self.padding = padding
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
        
        public init(backgroundColor: Color, title: Title, subtitle: Subtitle, detail: Detail, item: Item, cornerRadius: CGFloat, spacing: CGFloat, height: CGFloat) {
            self.backgroundColor = backgroundColor
            self.title = title
            self.subtitle = subtitle
            self.detail = detail
            self.item = item
            self.cornerRadius = cornerRadius
            self.spacing = spacing
            self.height = height
        }
    }
}
