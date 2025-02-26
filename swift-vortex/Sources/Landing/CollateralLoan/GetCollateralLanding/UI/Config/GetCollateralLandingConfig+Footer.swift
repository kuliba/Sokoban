//
//  GetCollateralLandingConfig+Footer.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension GetCollateralLandingConfig {
    
    struct Footer {
        
        let text: String
        let font: FontConfig
        let foreground: Color
        let background: Color
        let layouts: Layouts
        
        init(
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
        
        struct Layouts {
            
            let height: CGFloat
            let cornerRadius: CGFloat
            let paddings: EdgeInsets
            
            init(
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
    
    static let `default` = Self(
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
