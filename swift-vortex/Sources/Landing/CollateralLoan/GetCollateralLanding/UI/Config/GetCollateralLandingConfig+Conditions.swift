//
//  GetCollateralLandingConfig+Conditions.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import SwiftUI

extension GetCollateralLandingConfig {
    
    struct Conditions {
        
        let header: Header
        let list: List
        
        init(
            header: Header,
            list: List
        ) {
            
            self.header = header
            self.list = list
        }
        
        struct Header {
            
            let text: String
            let headerFont: FontConfig

            init(
                text: String,
                headerFont: FontConfig
            ) {
                
                self.text = text
                self.headerFont = headerFont
            }
        }
        
        struct List {

            let layouts: Layouts
            let fonts: Fonts
            let colors: Colors
            
            init(layouts: Layouts, fonts: Fonts, colors: Colors) {
                self.layouts = layouts
                self.fonts = fonts
                self.colors = colors
            }
            
            struct Layouts {
                
                let spacing: CGFloat
                let horizontalPadding: CGFloat
                let listTopPadding: CGFloat
                let iconSize: CGSize
                let iconTrailingPadding: CGFloat
                let subTitleTopPadding: CGFloat
                
                init(
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
            
            struct Fonts {
                
                let title: FontConfig
                let subTitle: FontConfig
                
                init(title: FontConfig, subTitle: FontConfig) {
                    self.title = title
                    self.subTitle = subTitle
                }
            }
            
            struct Colors {
                
                let background: Color
                let iconBackground: Color
                
                
                init(background: Color, iconBackground: Color) {
                    self.background = background
                    self.iconBackground = iconBackground
                }
            }
        }
    }
}

extension GetCollateralLandingConfig.Conditions {
    
    static let `default` = Self(
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
