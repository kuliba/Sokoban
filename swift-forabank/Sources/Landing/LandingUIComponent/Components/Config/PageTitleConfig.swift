//
//  PageTitleConfig.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension UILanding.PageTitle {
    
    struct Config {
        
        public let title: Title
        public let subtitle: Subtitle
                
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
            public let font: Font
            
            public init(color: Color, font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        func background(_ transparency: Bool) -> Color {
            
            transparency ? .clear : .white
        }
        
        public init(title: Title, subtitle: Subtitle) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
