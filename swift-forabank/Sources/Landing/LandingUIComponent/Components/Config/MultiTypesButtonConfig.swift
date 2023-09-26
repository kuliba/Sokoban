//
//  MultiTypesButtonConfig.swift
//  
//
//  Created by Andryusina Nataly on 21.09.2023.
//

import SwiftUI

public extension UILanding.Multi.TypeButtons {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let fonts: Fonts
        let spacing: CGFloat
        let sizes: Sizes
        let colors: Colors
        
        public struct Fonts {
            
            let into: Font
            let button: Font
            
            public init(into: Font, button: Font) {
                self.into = into
                self.button = button
            }
        }
        public struct Sizes {
            
            let imageInfo: CGFloat
            let heightButton: CGFloat
            
            public init(imageInfo: CGFloat, heightButton: CGFloat) {
                self.imageInfo = imageInfo
                self.heightButton = heightButton
            }
        }
        
        let paddings: Paddings
        
        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
        
        public struct Colors {
            
            let background: Background
            let button: Color
            let buttonText: Color
            let foreground: Foreground
            
            public struct Foreground {
                
                let fgBlack: Color
                let fgWhite: Color
                
                public init(fgBlack: Color, fgWhite: Color) {
                    self.fgBlack = fgBlack
                    self.fgWhite = fgWhite
                }
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
            
            public init(background: Background, button: Color, buttonText: Color, foreground: Foreground) {
                self.background = background
                self.button = button
                self.buttonText = buttonText
                self.foreground = foreground
            }
        }
        
        public init(
            cornerRadius: CGFloat,
            fonts: Fonts,
            spacing: CGFloat,
            sizes: Sizes,
            colors: Colors,
            paddings: Paddings
        ) {
            self.cornerRadius = cornerRadius
            self.fonts = fonts
            self.spacing = spacing
            self.sizes = sizes
            self.colors = colors
            self.paddings = paddings
        }
                
        func backgroundColor(_ backgroundColor: String) -> Color {
            
            let colorType: BackgroundColorType = .init(rawValue: backgroundColor) ?? .white
                
            switch colorType {
                
            case .black:
                return self.colors.background.black
            case .gray:
                return self.colors.background.gray
            case .white:
                return self.colors.background.white
            }
        }
            
        func textColor(_ backgroundColor: String) -> Color {
            
            let colorType: BackgroundColorType = .init(rawValue: backgroundColor) ?? .white

            switch colorType {
                
            case .black:
                return self.colors.foreground.fgWhite
            case .gray, .white:
                return self.colors.foreground.fgBlack
            }
        }
    }
}
