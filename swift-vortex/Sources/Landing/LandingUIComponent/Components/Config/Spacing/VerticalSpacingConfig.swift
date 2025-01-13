//
//  VerticalSpacingConfig.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import SwiftUI

public extension UILanding.VerticalSpacing {
    
    struct Config {
        
        public let spacing: Spacing
        public let background: Background
        
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

        public struct Spacing {
            
            public let big: CGFloat
            public let small: CGFloat
            public let negativeOffset: CGFloat
            
            public init(big: CGFloat, small: CGFloat, negativeOffset: CGFloat) {
                self.big = big
                self.small = small
                self.negativeOffset = negativeOffset
            }
        }
        
        public init(spacing: Spacing, background: Background) {
            self.spacing = spacing
            self.background = background
        }
        
        func value(byType type:UILanding.VerticalSpacing.SpacingType) -> CGFloat {
            
            switch type {
                
            case .small:
                return self.spacing.small
                
            case .big:
                return self.spacing.big

            case .negativeOffset:
                return self.spacing.negativeOffset
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
