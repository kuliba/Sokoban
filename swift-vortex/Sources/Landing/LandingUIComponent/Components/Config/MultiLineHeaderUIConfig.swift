//
//  MultiLineHeaderUIConfig.swift
//  
//
//  Created by Andryusina Nataly on 28.08.2023.
//

import SwiftUI

public extension UILanding.Multi.LineHeader {
    
    struct Config {
        
        public var id: Self { self }
        
        public let paddings: Paddings
        public let item: Item
        public let background: Background
        public let foreground: Foreground
        
        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
        
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
        
        public struct Item {
            
            public let fontRegular: Font
            public let fontBold: Font
            
            public init(
                fontRegular: Font,
                fontBold: Font
            ) {
                self.fontRegular = fontRegular
                self.fontBold = fontBold
            }
        }
        
        public init(paddings: Paddings, item: Item, background: Background, foreground: Foreground) {
            self.paddings = paddings
            self.item = item
            self.background = background
            self.foreground = foreground
        }
                
        func backgroundColor(_ backgroundColor: String) -> Color {
            
            let colorType: BackgroundColorType = .init(rawValue: backgroundColor) ?? .white
                
            switch colorType {
                
            case .black:
                return background.black
            case .gray:
                return background.gray
            case .white:
                return background.white
            }
        }
            
        func textColor(_ backgroundColor: String) -> Color {
            
            let colorType: BackgroundColorType = .init(rawValue: backgroundColor) ?? .white

            switch colorType {
                
            case .black:
                return foreground.fgWhite
            case .gray, .white:
                return foreground.fgBlack
            }
        }
    }
}
