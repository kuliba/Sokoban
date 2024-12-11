//
//  CollateralLoanLandingGetCollateralLandingViewConfig+Footer.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension CollateralLoanLandingGetCollateralLandingViewConfig {
    
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
            let paddings: Paddings
            
            init(height: CGFloat, cornerRadius: CGFloat, paddings: Paddings) {
                self.height = height
                self.cornerRadius = cornerRadius
                self.paddings = paddings
            }
            
            struct Paddings {
                    
                let leading: CGFloat
                let trailing: CGFloat
                let top: CGFloat
                let bottom: CGFloat
                
                init(
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
