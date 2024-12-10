//
//  CollateralLoanLandingGetCollateralLandingViewConfig+Documents.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import SwiftUI

extension CollateralLoanLandingGetCollateralLandingViewConfig {
    
    public struct Documents {
        
        public let background: Color
        public let topPadding: CGFloat
        public let header: Header
        public let list: List
        
        public init(background: Color, topPadding: CGFloat, header: Header, list: List) {
            self.background = background
            self.topPadding = topPadding
            self.header = header
            self.list = list
        }
        
        public struct Header {
            
            public let text: String
            public let headerFont: FontConfig

            public init(
                text: String,
                headerFont: FontConfig
            ) {
                
                self.text = text
                self.headerFont = headerFont
            }
        }
        
        public struct List {
            
            public let layouts: Layouts
            public let fonts: Fonts
            public let colors: Colors
            
            public init(layouts: Layouts, fonts: Fonts, colors: Colors) {
                self.layouts = layouts
                self.fonts = fonts
                self.colors = colors
            }
            
            public struct Layouts {
                
                public let horizontalPadding: CGFloat
                public let topPadding: CGFloat
                public let bottomPadding: CGFloat
                public let spacing: CGFloat
                public let iconTrailingPadding: CGFloat
                
                public init(
                    horizontalPadding: CGFloat,
                    topPadding: CGFloat,
                    bottomPadding: CGFloat,
                    spacing: CGFloat,
                    iconTrailingPadding: CGFloat
                ) {
                    self.horizontalPadding = horizontalPadding
                    self.topPadding = topPadding
                    self.bottomPadding = bottomPadding
                    self.spacing = spacing
                    self.iconTrailingPadding = iconTrailingPadding
                }
            }
            
            public struct Fonts {
                
                public let title: FontConfig
                
                public init(title: FontConfig) {
                    self.title = title
                }
            }
            
            public struct Colors {
                
            }
        }
    }
}

extension CollateralLoanLandingGetCollateralLandingViewConfig.Documents {
    
    static let `default` = Self(
        background: .grayLightest,
        topPadding: 16,
        header: .init(
            text: "Документы",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            layouts: .init(
                horizontalPadding: 16,
                topPadding: 8,
                bottomPadding: 6,
                spacing: 13,
                iconTrailingPadding: 16
            ),
            fonts: .init(
                title: .init(Font.system(size: 14))
            ),
            colors: .init()
        )
    )
}
