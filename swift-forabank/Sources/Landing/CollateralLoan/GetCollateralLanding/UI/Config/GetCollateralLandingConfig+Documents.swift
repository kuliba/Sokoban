//
//  GetCollateralLandingConfig+Documents.swift
//
//
//  Created by Valentin Ozerov on 20.11.2024.
//

import SwiftUI

extension GetCollateralLandingConfig {
    
    struct Documents {
        
        let background: Color
        let topPadding: CGFloat
        let header: Header
        let list: List
        
        init(background: Color, topPadding: CGFloat, header: Header, list: List) {
            self.background = background
            self.topPadding = topPadding
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
            
            init(layouts: Layouts, fonts: Fonts) {
                self.layouts = layouts
                self.fonts = fonts
            }
            
            struct Layouts {
                
                let horizontalPadding: CGFloat
                let topPadding: CGFloat
                let bottomPadding: CGFloat
                let spacing: CGFloat
                let iconTrailingPadding: CGFloat
                
                init(
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
            
            struct Fonts {
                
                let title: FontConfig
                
                init(title: FontConfig) {
                    self.title = title
                }
            }
        }
    }
}

extension GetCollateralLandingConfig.Documents {
    
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
            )
        )
    )
}
