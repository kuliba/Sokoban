//
//  ClientInformListConfig.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI
import SharedConfigs

public struct ClientInformListConfig {
    
    let colors: Colors
    let strings: Strings
    let titleConfig: TextConfig
    let textConfig: TextConfig
    let sizes: Sizes
    let paddings: Paddings
    let image: Image

    public struct Colors {
        
        let grayBackground: Color
        let bgIconRedLight: Color
        
        public init(
            grayBackground: Color,
            bgIconRedLight: Color
        ) {
            self.grayBackground = grayBackground
            self.bgIconRedLight = bgIconRedLight
        }
    }
    
    public struct Sizes {
        
        let iconSize: CGFloat
        let iconBackgroundSize: CGFloat
        let rowIconSize: CGFloat
        let navBarHeight: CGFloat
        let navBarMaxWidth: CGFloat
        let spacing: CGFloat
        let bigSpacing: CGFloat

        public init(
            iconSize: CGFloat,
            iconBackgroundSize: CGFloat,
            rowIconSize: CGFloat,
            navBarHeight: CGFloat,
            navBarMaxWidth: CGFloat,
            spacing: CGFloat,
            bigSpacing: CGFloat
        ) {
            
            self.iconSize = iconSize
            self.iconBackgroundSize = iconBackgroundSize
            self.rowIconSize = rowIconSize
            self.navBarHeight = navBarHeight
            self.navBarMaxWidth = navBarMaxWidth
            self.spacing = spacing
            self.bigSpacing = bigSpacing
        }
    }
    
    public struct Paddings {
                
        let topImage: CGFloat
        let horizontal: CGFloat
        let vertical: CGFloat
        
        public init(
            topImage: CGFloat,
            horizontal: CGFloat,
            vertical: CGFloat
        ) {
            self.topImage = topImage
            self.horizontal = horizontal
            self.vertical = vertical
        }
    }
    
    public struct Strings {
        
        let titlePlaceholder: String
        
        public init(titlePlaceholder: String) {
            self.titlePlaceholder = titlePlaceholder
        }
    }
    
    public init(
        colors: Colors,
        strings: Strings,
        titleConfig: TextConfig,
        textConfig: TextConfig,
        sizes: Sizes,
        paddings: Paddings,
        image: Image
    ) {
        self.colors = colors
        self.strings = strings
        self.titleConfig = titleConfig
        self.textConfig = textConfig
        self.sizes = sizes
        self.paddings = paddings
        self.image = image
    }
}
