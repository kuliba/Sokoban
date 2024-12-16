//
//  MultiTextsWithIconsHorizontalUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

import SwiftUI

public extension UILanding.Multi.TextsWithIconsHorizontal {
    
    struct Config {
        
        public let color: Color
        public let font: Font
        public let size: CGFloat
        public let padding: Paddings
        
        public struct Paddings {
            
            public let horizontal: CGFloat
            public let vertical: CGFloat
            public let itemVertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat, itemVertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
                self.itemVertical = itemVertical
            }
        }
        
        public init(
            color: Color,
            font: Font,
            size: CGFloat,
            padding: Paddings
        ) {
            self.color = color
            self.font = font
            self.size = size
            self.padding = padding
        }
    }
}
