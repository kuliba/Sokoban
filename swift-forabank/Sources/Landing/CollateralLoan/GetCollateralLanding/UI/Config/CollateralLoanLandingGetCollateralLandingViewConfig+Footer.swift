//
//  CollateralLoanLandingGetCollateralLandingViewConfig+Footer.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension CollateralLoanLandingGetCollateralLandingViewConfig {
    
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
            public let paddings: Paddings
            
            public init(height: CGFloat, cornerRadius: CGFloat, paddings: Paddings) {
                self.height = height
                self.cornerRadius = cornerRadius
                self.paddings = paddings
            }
            
            public struct Paddings {
                    
                public let leading: CGFloat
                public let trailing: CGFloat
                public let top: CGFloat
                public let bottom: CGFloat
                
                public init(
                    leading: CGFloat,
                    trailing: CGFloat,
                    top: CGFloat,
                    bottom: CGFloat
                ) {
                    self.leading = leading
                    self.trailing = trailing
                    self.top = top
                    self.bottom = bottom
                }
            }
        }
    }
}

extension CollateralLoanLandingGetCollateralLandingViewConfig.Footer {
    
    static let `default` = Self(
        text: "Оформить заявку",
        font: .init(Font.system(size: 24).bold()),
        foreground: .white,
        background: .red,
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(
                leading: 16,
                trailing: 15,
                top: 16,
                bottom: 25
            )
        )
    )
}
