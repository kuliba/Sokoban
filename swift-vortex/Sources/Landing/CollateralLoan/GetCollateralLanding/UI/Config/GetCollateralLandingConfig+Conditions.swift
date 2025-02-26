//
//  GetCollateralLandingConfig+Conditions.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import SwiftUI

extension GetCollateralLandingConfig {
    
    public struct Conditions {
        
        public let header: Header
        public let list: List
        
        public init(
            header: Header,
            list: List
        ) {
            
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
                
                public let spacing: CGFloat
                public let horizontalPadding: CGFloat
                public let listTopPadding: CGFloat
                public let iconSize: CGSize
                public let iconTrailingPadding: CGFloat
                public let subTitleTopPadding: CGFloat
                
                public init(
                    spacing: CGFloat,
                    horizontalPadding: CGFloat,
                    listTopPadding: CGFloat,
                    iconSize: CGSize,
                    iconTrailingPadding: CGFloat,
                    subTitleTopPadding: CGFloat
                ) {
                    self.spacing = spacing
                    self.horizontalPadding = horizontalPadding
                    self.listTopPadding = listTopPadding
                    self.iconSize = iconSize
                    self.iconTrailingPadding = iconTrailingPadding
                    self.subTitleTopPadding = subTitleTopPadding
                }
            }
            
            public struct Fonts {
                
                public let title: FontConfig
                public let subTitle: FontConfig
                
                public init(title: FontConfig, subTitle: FontConfig) {
                    self.title = title
                    self.subTitle = subTitle
                }
            }
            
            public struct Colors {
                
                public let background: Color
                public let iconBackground: Color
                
                
                public init(background: Color, iconBackground: Color) {
                    self.background = background
                    self.iconBackground = iconBackground
                }
            }
        }
    }
}

extension GetCollateralLandingConfig.Conditions {
    
    static let preview = Self(
        header: .init(
            text: "Выгодные условия",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            layouts: .init(
                spacing: 13,
                horizontalPadding: 16,
                listTopPadding: 12,
                iconSize: CGSize(width: 40, height: 40),
                iconTrailingPadding: 16,
                subTitleTopPadding: 2
            ),
            fonts: .init(
                title: .init(Font.system(size: 14), foreground: .textPlaceholder),
                subTitle: .init(Font.system(size: 16))),
            colors: .init(
                background: .grayLightest,
                iconBackground: .iconBackground
            )
        )
    )
}
