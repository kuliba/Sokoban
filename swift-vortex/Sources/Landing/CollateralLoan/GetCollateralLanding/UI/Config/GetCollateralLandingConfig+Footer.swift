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
        public let foreground: Color
        public let background: Color
        public let layouts: Layouts
        
        public init(
            text: String,
            font: FontConfig,
            foreground: Color,
            background: Color,
            layouts: Layouts
        ) {
            self.text = text
            self.font = font
            self.foreground = foreground
            self.background = background
            self.layouts = layouts
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
        foreground: .white,
        background: .red,
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(top: 16, leading: 16, bottom: 0, trailing: 15)
        )
    )
}
