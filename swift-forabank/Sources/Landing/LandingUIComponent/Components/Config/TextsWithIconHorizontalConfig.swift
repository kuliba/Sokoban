//
//  TextsWithIconHorizontalConfig.swift
//  
//
//  Created by Andryusina Nataly on 08.09.2023.
//

import SwiftUI

public extension UILanding.TextsWithIconHorizontal {
    
    struct Config {
        
        public let paddings: Paddings
        public let backgroundColor: Color
        public let cornerRadius: CGFloat
        public let circleSize: CGFloat
        public let icon: Icon
        public let height: CGFloat
        public let spacing: CGFloat
        public let text: Text
        public let images: [String: Image]
        
        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
        
        public struct Icon {
            
            public let width: CGFloat
            public let height: CGFloat
            public let placeholderColor: Color
            public let padding: Paddings
            
            public struct Paddings {
                
                let vertical: CGFloat
                let leading: CGFloat
                
                public init(vertical: CGFloat, leading: CGFloat) {
                    self.vertical = vertical
                    self.leading = leading
                }
            }
            
            public init(width: CGFloat, height: CGFloat, placeholderColor: Color, padding: Paddings) {
                self.width = width
                self.height = height
                self.placeholderColor = placeholderColor
                self.padding = padding
            }
        }
        
        public struct Text {
            
            public let color: Color
            public let font: Font
            
            public init(color: Color, 
                        font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        public init(
            paddings: Paddings,
            backgroundColor: Color,
            cornerRadius: CGFloat,
            circleSize: CGFloat,
            icon: Icon, height: CGFloat,
            spacing: CGFloat,
            text: Text,
            images: [String: Image]
        ) {
            self.paddings = paddings
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.circleSize = circleSize
            self.icon = icon
            self.height = height
            self.spacing = spacing
            self.text = text
            self.images = images
        }
    }
}


