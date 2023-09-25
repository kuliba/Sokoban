//
//  TextsWithIconHorizontalConfig.swift
//  
//
//  Created by Andryusina Nataly on 08.09.2023.
//

import SwiftUI

public extension UILanding.TextsWithIconHorizontal {
    
    struct Config {
        
        public let backgroundColor: Color
        public let cornerRadius: CGFloat
        public let icon: Icon
        public let height: CGFloat
        public let spacing: CGFloat
        
        public let text: Text
        
        public struct Icon {
            
            public let size: CGFloat
            public let placeholderColor: Color
            
            public init(iconSize: CGFloat, placeholderColor: Color) {
                self.size = iconSize
                self.placeholderColor = placeholderColor
            }
        }
        
        public struct Text {
            
            public let color: Color
            public let font: Font
            
            public init(color: Color, font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        public init(
            backgroundColor: Color,
            cornerRadius: CGFloat,
            icon: Icon,
            height: CGFloat,
            spacing: CGFloat,
            text: Text
        ) {
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.icon = icon
            self.height = height
            self.spacing = spacing
            self.text = text
        }
    }
}


