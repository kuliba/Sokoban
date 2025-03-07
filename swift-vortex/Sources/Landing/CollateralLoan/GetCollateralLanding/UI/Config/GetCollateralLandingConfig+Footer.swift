//
//  GetCollateralLandingConfig+Footer.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension GetCollateralLandingConfig {
    
    public struct Footer {
        
        public let text: String
        public let font: FontConfig
        public let colors: Colors
        public let layouts: Layouts
        
        public init(
            text: String,
            font: FontConfig,
            colors: Colors,
            layouts: Layouts
        ) {
            self.text = text
            self.font = font
            self.colors = colors
            self.layouts = layouts
        }
        
        public struct Colors {
            
            public let buttonForeground: Color
            public let buttonBackground: Color
            public let disabledButtonBackground: Color
            public let background: Color
            
            public init(
                buttonForeground: Color,
                buttonBackground: Color,
                disabledButtonBackground: Color,
                background: Color
            ) {
                self.buttonForeground = buttonForeground
                self.buttonBackground = buttonBackground
                self.disabledButtonBackground = disabledButtonBackground
                self.background = background
            }
        }
        
        public struct Layouts {
            
            public let height: CGFloat
            public let cornerRadius: CGFloat
            public let paddings: EdgeInsets
            
            public init(
                height: CGFloat,
                cornerRadius: CGFloat,
                paddings: EdgeInsets
            ) {
                self.height = height
                self.cornerRadius = cornerRadius
                self.paddings = paddings
            }
        }
    }
}

extension GetCollateralLandingConfig.Footer {
    
    static let preview = Self(
        text: "Оформить заявку",
        font: .init(Font.system(size: 16).bold()),
        colors: .init(
            buttonForeground: .white,
            buttonBackground: .red,
            disabledButtonBackground: .unselected,
            background: .grayLightest
        ),
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(top: 16, leading: 16, bottom: 0, trailing: 15)
        )
    )
}
