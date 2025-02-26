//
//  CreateDraftCollateralLoanApplicationConfig+Button.swift
//
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import Foundation
import SwiftUI

extension CreateDraftCollateralLoanApplicationConfig {
    
    public struct Button {
        
        public let continueTitle: String
        public let createTitle: String
        public let colors: Colors
        public let font: FontConfig
        public let layouts: Layouts
        
        public init(
            continueTitle: String,
            createTitle: String,
            colors: Colors,
            font: FontConfig,
            layouts: Layouts
        ) {
            self.continueTitle = continueTitle
            self.createTitle = createTitle
            self.colors = colors
            self.font = font
            self.layouts = layouts
        }
        
        public struct Colors {
            
            public let foreground: Color
            public let background: Color
            public let disabled: Color
            
            public init(foreground: Color, background: Color, disabled: Color) {
                
                self.foreground = foreground
                self.background = background
                self.disabled = disabled
            }
        }
        
        public struct Layouts {
            
            public let height: CGFloat
            public let cornerRadius: CGFloat
            public let paddings: EdgeInsets

            public init(height: CGFloat, cornerRadius: CGFloat, paddings: EdgeInsets) {
                
                self.height = height
                self.cornerRadius = cornerRadius
                self.paddings = paddings
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationConfig.Button {
    
    static let preview = Self(
        continueTitle: "Продолжить",
        createTitle: "Оформить заявку",
        colors: .init(
            foreground: .white,
            background: .red,
            disabled: .unselected
        ),
        font: .init(Font.system(size: 16).bold()),
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(top: 12, leading: 16, bottom: 0, trailing: 15)
        )
    )
}

private extension Color {
    
    static let unselected: Self = .init(red: 0.92, green: 0.92, blue: 0.92)
}
