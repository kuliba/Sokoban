//
//  MultiButtonsConfig.swift
//
//  Created by Andrew Kurdin on 20.09.2023.
//

import SwiftUI

public extension UILanding.Multi.Buttons {
    
    struct Config {
        
        public let settings: Settings
        public let buttons: Buttons
        
        public struct Settings {
            public let spacing: CGFloat
            public let padding: PaddingForMain
            
            public init(spacing: CGFloat, padding: PaddingForMain) {
                self.spacing = spacing
                self.padding = padding
            }
        }
        
        public struct Buttons {
            
            public let backgroundColors: Colors
            public let textColors: Colors
            public let padding: PaddingForButtons
            public let font: Font
            public let height: CGFloat
            public let cornerRadius: CGFloat
                                    
            public init(
                backgroundColors: Colors,
                textColors: Colors,
                padding: PaddingForButtons,
                font: Font,
                height: CGFloat,
                cornerRadius: CGFloat
            ) {
                self.backgroundColors = backgroundColors
                self.textColors = textColors
                self.padding = padding
                self.font = font
                self.height = height
                self.cornerRadius = cornerRadius
            }
        }
        
        public struct PaddingForMain {
            
            public let horiontal: CGFloat
            public let top: CGFloat
            public let bottom: CGFloat
            
            public init(horiontal: CGFloat, top: CGFloat, bottom: CGFloat) {
                self.horiontal = horiontal
                self.top = top
                self.bottom = bottom
            }
        }
        
        public struct PaddingForButtons {
            
            public let horiontal: CGFloat
            public let vertical: CGFloat
            
            public init(horiontal: CGFloat, vertical: CGFloat) {
                self.horiontal = horiontal
                self.vertical = vertical
            }
        }
        
        public struct Colors {
            
            public let first: Color
            public let second: Color
            
            public init(first: Color, second: Color) {
                self.first = first
                self.second = second
            }
        }

        public init(settings: Settings, buttons: Buttons) {
            self.settings = settings
            self.buttons = buttons
        }
        
        func backgroundColor(
            style: String
        ) -> Color {
            if style == "whiteRed" { return buttons.backgroundColors.first }
            return buttons.backgroundColors.second
        }
        
        func textColor(
            style: String
        ) -> Color {
            if style == "whiteRed" { return buttons.textColors.first }
            return buttons.textColors.second
        }
    }
}
