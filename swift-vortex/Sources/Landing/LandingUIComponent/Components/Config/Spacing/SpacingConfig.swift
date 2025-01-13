//
//  SpacingConfig.swift
//  
//
//  Created by Andryusina Nataly on 30.09.2024.
//

import SwiftUI

public extension UILanding.Spacing {
    
    struct Config {
        
        public let background: Background
        
        public init(background: Background) {
            self.background = background
        }
        
        public struct Background {
            let black: Color
            let gray: Color
            let white: Color
            
            public init(black: Color, gray: Color, white: Color) {
                self.black = black
                self.gray = gray
                self.white = white
            }
        }
                
        func backgroundColor(_ backgroundColor: BackgroundColorType) -> Color {
            
            switch backgroundColor {
                
            case .black:
                return background.black
            case .gray:
                return background.gray
            case .white:
                return background.white
            }
        }
    }
}
