//
//  PageTitleUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public extension Landing.PageTitle {
    
    struct Config: Equatable {
        
        public let title: Title
        public let subtitle: Subtitle
        public let transparency: Bool
                
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
            public let font: Font
            
            public init(color: Color, font: Font) {
                self.color = color
                self.font = font
            }
        }
        
        var background: Color {
            
            transparency ? .clear : .white
        }
        
        public init(title: Title, subtitle: Subtitle, transparency: Bool) {
            self.title = title
            self.subtitle = subtitle
            self.transparency = transparency
        }
    }
}
