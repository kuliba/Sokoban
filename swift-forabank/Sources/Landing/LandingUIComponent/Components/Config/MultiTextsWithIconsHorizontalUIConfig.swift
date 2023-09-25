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
        public let padding: CGFloat
        
        public init(
            color: Color,
            font: Font,
            size: CGFloat,
            padding: CGFloat
        ) {
            self.color = color
            self.font = font
            self.size = size
            self.padding = padding
        }
    }
}
