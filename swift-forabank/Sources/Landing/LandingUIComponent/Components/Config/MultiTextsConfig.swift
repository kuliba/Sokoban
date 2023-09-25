//
//  MultiTextsConfig.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import SwiftUI

public extension UILanding.Multi.Texts {
    
    struct Config {
        
        public let font: Font
        public let colors: Colors
        public let paddings: Paddings
        public let cornerRadius: CGFloat
        public let spacing: CGFloat
        
        public struct Colors: Hashable {
            
            public let text: Color
            public let background: Color
            
            public init(text: Color, background: Color) {
                self.text = text
                self.background = background
            }
        }
        
        public struct Paddings: Hashable {
            
            public let main: Padding
            public let inside: Padding
            
            public struct Padding: Hashable {
                
                public let horizontal: CGFloat
                public let vertical: CGFloat
                
                public init(horizontal: CGFloat, vertical: CGFloat) {
                    self.horizontal = horizontal
                    self.vertical = vertical
                }
            }
            
            public init(main: Padding, inside: Padding) {
                self.main = main
                self.inside = inside
            }
        }
        
        public init(
            font: Font,
            colors: Colors,
            paddings: Paddings,
            cornerRadius: CGFloat,
            spacing: CGFloat
        ) {
            self.font = font
            self.colors = colors
            self.paddings = paddings
            self.cornerRadius = cornerRadius
            self.spacing = spacing
        }
    }
}
