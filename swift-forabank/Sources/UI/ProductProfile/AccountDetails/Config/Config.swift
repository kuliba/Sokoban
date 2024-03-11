//
//  Config.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

public struct Config {
    
    let images: Images
    let iconSize: CGFloat
    let colors: Colors
    let fonts: Fonts
    
    public init(
        images: Images,
        iconSize: CGFloat,
        colors: Colors,
        fonts: Fonts
    ) {
        self.images = images
        self.iconSize = iconSize
        self.colors = colors
        self.fonts = fonts
    }
}

public extension Config {
    
    struct Images {
        
        let maskedValue: Image
        let showValue: Image
        let checkOn: Image
        let checkOff: Image
        let info: Image
        
        public init(
            maskedValue: Image,
            showValue: Image,
            checkOn: Image,
            checkOff: Image,
            info: Image
        ) {
            self.maskedValue = maskedValue
            self.showValue = showValue
            self.checkOn = checkOn
            self.checkOff = checkOff
            self.info = info
        }
    }
}

public extension Config {
    
    struct Colors {
        
        let image: Color
        let title: Color
        let subtitle: Color
        let fill: Color
        let checkBoxTitle: Color
        let divider: Color
        
        public init(
            image: Color,
            title: Color,
            subtitle: Color,
            fill: Color,
            checkBoxTitle: Color,
            divider: Color = Color(red: 0.83, green: 0.83, blue: 0.83).opacity(0.3)
        ) {
            self.image = image
            self.title = title
            self.subtitle = subtitle
            self.fill = fill
            self.checkBoxTitle = checkBoxTitle
            self.divider = divider
        }
    }
}

public extension Config {
    
    struct Fonts {
        
        let title: Font
        let subtitle: Font
        let checkBoxTitle: Font
        
        public init(
            title: Font,
            subtitle: Font,
            checkBoxTitle: Font
        ) {
            self.title = title
            self.subtitle = subtitle
            self.checkBoxTitle = checkBoxTitle
        }
    }
}
