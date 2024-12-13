//
//  GetCollateralLandingConfig+Header.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension GetCollateralLandingConfig {
    
    struct Header {
        
        let height: CGFloat
        let labelTag: LabelTag
        let params: Params
        
        init(
            height: CGFloat,
            labelTag: LabelTag,
            params: Params
        ) {
            self.height = height
            self.labelTag = labelTag
            self.params = params
        }
        
        struct LabelTag {

            let layouts: Layouts
            let fonts: Fonts

            init(layouts: Layouts, fonts: Fonts) {
                self.layouts = layouts
                self.fonts = fonts
            }
            
            struct Layouts {
                
                let cornerSize: CGFloat
                let topOuterPadding: CGFloat
                let leadingOuterPadding: CGFloat
                let horizontalInnerPadding: CGFloat
                let verticalInnerPadding: CGFloat
                let rotationDegrees: CGFloat
            }
            
            struct Fonts {
                
                let fontConfig: FontConfig
            }
        }
        
        struct Params {
            
            let fontConfig: FontConfig
            let spacing: CGFloat
            let leadingPadding: CGFloat
            let topPadding: CGFloat
            
            init(
                fontConfig: FontConfig,
                spacing: CGFloat,
                leadingPadding: CGFloat,
                topPadding: CGFloat
            ) {
                self.fontConfig = fontConfig
                self.spacing = spacing
                self.leadingPadding = leadingPadding
                self.topPadding = topPadding
            }
        }
    }
}

extension GetCollateralLandingConfig.Header {
    
    static let `default` = Self(
        height: 642,
        labelTag: .init(
            layouts: .init(
                cornerSize: 10,
                topOuterPadding: 215,
                leadingOuterPadding: 25,
                horizontalInnerPadding: 10,
                verticalInnerPadding: 6,
                rotationDegrees: -5
            ),
            fonts: .init(fontConfig: .init(
                Font.system(size: 32).bold(),
                foreground: .white,
                background: .red
            ))
        ),
        params: .init(
            fontConfig: .init(Font.system(size: 14)),
            spacing: 20,
            leadingPadding: 20,
            topPadding: 30
        )
    )
}
