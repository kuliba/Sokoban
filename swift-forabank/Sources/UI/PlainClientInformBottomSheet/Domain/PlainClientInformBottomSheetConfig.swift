//
//  PlainClientInformBottomSheetConfig.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 08.10.2024.
//

import SwiftUI
import SharedConfigs

public struct PlainClientInformBottomSheetConfig {
    
    let colors: Colors
    let strings: Strings
    let titleConfig: TextConfig
    let textConfig: TextConfig
    let sizes: Sizes
    let paddings: Paddings

    public struct Colors {
        
        let grayGrabber: Color
        let grayBackground: Color
        
        init(
            grayGrabber: Color,
            grayBackground: Color
        ) {
            self.grayGrabber = grayGrabber
            self.grayBackground = grayBackground
        }
    }
    
    public struct Sizes {
        
        let iconSize: CGFloat
        let rowIconSize: CGFloat
        let navBarHeight: CGFloat
        let navBarMaxWidth: CGFloat
        let grabberWidth: CGFloat
        let grabberHeight: CGFloat
        let grabberCornerRadius: CGFloat
        let spacing: CGFloat

        public init(
            iconSize: CGFloat,
            rowIconSize: CGFloat,
            navBarHeight: CGFloat,
            navBarMaxWidth: CGFloat,
            grabberWidth: CGFloat,
            grabberHeight: CGFloat,
            grabberCornerRadius: CGFloat,
            spacing: CGFloat
        ) {
            
            self.iconSize = iconSize
            self.rowIconSize = rowIconSize
            self.navBarHeight = navBarHeight
            self.navBarMaxWidth = navBarMaxWidth
            self.grabberWidth = grabberWidth
            self.grabberHeight = grabberHeight
            self.grabberCornerRadius = grabberCornerRadius
            self.spacing = spacing
        }
    }
    
    public struct Paddings {
                
        let topGrabber: CGFloat
        let topImage: CGFloat
        let horizontal: CGFloat
        let vertical: CGFloat
        
        public init(
            topGrabber: CGFloat,
            topImage: CGFloat,
            horizontal: CGFloat,
            vertical: CGFloat
        ) {
            self.topGrabber = topGrabber
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
        image: Image,
        rowImage: Image
    ) {
        
        self.colors = colors
        self.strings = strings
        self.titleConfig = titleConfig
        self.textConfig = textConfig
        self.sizes = sizes
        self.paddings = paddings
    }
    
}
