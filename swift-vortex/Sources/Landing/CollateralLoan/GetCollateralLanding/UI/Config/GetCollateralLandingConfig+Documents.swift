//
//  GetCollateralLandingConfig+Documents.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import SwiftUI

extension GetCollateralLandingConfig {
    
    public struct Documents {
        
        public let background: Color
        public let topPadding: CGFloat
        public let header: Header
        public let list: List
        
        public init(
            background: Color,
            topPadding: CGFloat,
            header: Header,
            list: List
        ) {
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
            
            public let defaultIcon: Image
            public let layouts: Layouts
            public let fonts: Fonts
            
            public init(
                defaultIcon: Image,
                layouts: Layouts,
                fonts: Fonts
            ) {
                self.defaultIcon = defaultIcon
                self.layouts = layouts
                self.fonts = fonts
            }
            
            public struct Layouts {
                
                public let horizontalPadding: CGFloat
                public let topPadding: CGFloat
                public let bottomPadding: CGFloat
                public let spacing: CGFloat
                public let iconTrailingPadding: CGFloat
                public let iconSize: CGSize
                
                public init(
                    horizontalPadding: CGFloat,
                    topPadding: CGFloat,
                    bottomPadding: CGFloat,
                    spacing: CGFloat,
                    iconTrailingPadding: CGFloat,
                    iconSize: CGSize
                ) {
                    self.horizontalPadding = horizontalPadding
                    self.topPadding = topPadding
                    self.bottomPadding = bottomPadding
                    self.spacing = spacing
                    self.iconTrailingPadding = iconTrailingPadding
                    self.iconSize = iconSize
                }
            }
            
            public struct Fonts {
                
                public let title: FontConfig
                
                public init(
                    title: FontConfig
                ) {
                    self.title = title
                }
            }
        }
    }
}

extension GetCollateralLandingConfig.Documents {
    
    static let preview = Self(
        background: .grayLightest,
        topPadding: 16,
        header: .init(
            text: "Документы",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            defaultIcon: Image("file-text"),
            layouts: .init(
                horizontalPadding: 16,
                topPadding: 8,
                bottomPadding: 6,
                spacing: 13,
                iconTrailingPadding: 16,
                iconSize: .init(width: 20, height: 20)
            ),
            fonts: .init(
                title: .init(Font.system(size: 14))
            )
        )
    )
}
