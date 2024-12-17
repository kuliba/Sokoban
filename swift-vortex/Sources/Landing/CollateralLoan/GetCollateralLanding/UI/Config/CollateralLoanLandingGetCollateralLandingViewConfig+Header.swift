//
//  CollateralLoanLandingGetCollateralLandingViewConfig+Header.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import Foundation
import SwiftUI

extension CollateralLoanLandingGetCollateralLandingViewConfig {
    
    public struct Header {
        
        public let height: CGFloat
        public let labelTag: LabelTag
        public let params: Params
        
        public init(
            height: CGFloat,
            labelTag: LabelTag,
            params: Params
        ) {
            self.height = height
            self.labelTag = labelTag
            self.params = params
        }
        
        public struct LabelTag {

            public let layouts: Layouts
            public let fonts: Fonts

            public init(layouts: Layouts, fonts: Fonts) {
                self.layouts = layouts
                self.fonts = fonts
            }
            
            public struct Layouts {
                
                public let cornerSize: CGFloat
                public let topOuterPadding: CGFloat
                public let leadingOuterPadding: CGFloat
                public let horizontalInnerPadding: CGFloat
                public let verticalInnerPadding: CGFloat
                public let rotationDegrees: CGFloat
            }
            
            public struct Fonts {
                
                public let fontConfig: FontConfig
            }
        }
        
        public struct Params {
            
            public let fontConfig: FontConfig
            public let spacing: CGFloat
            public let leadingPadding: CGFloat
            public let topPadding: CGFloat
            
            public init(
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

extension CollateralLoanLandingGetCollateralLandingViewConfig.Header {
    
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
