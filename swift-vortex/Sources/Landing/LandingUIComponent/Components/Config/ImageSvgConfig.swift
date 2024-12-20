//
//  ImageSvgConfig.swift
//  
//
//  Created by Andryusina Nataly on 20.09.2023.
//

import SwiftUI

public extension UILanding.ImageSvg {
    
    struct Config {
        
        public let background: Background
        public let paddings: Paddings
        public let cornerRadius: CGFloat
        
        public struct Background {
            let black: Color
            let gray: Color
            let white: Color
            let defaultColor: Color

            public init(black: Color, gray: Color, white: Color, defaultColor: Color) {
                self.black = black
                self.gray = gray
                self.white = white
                self.defaultColor = defaultColor
            }
        }

        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
        
        public init(background: Background, paddings: Paddings, cornerRadius: CGFloat) {
            self.background = background
            self.paddings = paddings
            self.cornerRadius = cornerRadius
        }
        
        func backgroundColor(_ backgroundColor: String, defaultColor: Color) -> Color {
            
            let colorType: BackgroundColorType? = .init(rawValue: backgroundColor)
                
            switch colorType {
                
            case .black:
                return background.black
            case .gray:
                return background.gray
            case .white:
                return background.white
            case .none:
                return defaultColor
            }
        }
    }
}
