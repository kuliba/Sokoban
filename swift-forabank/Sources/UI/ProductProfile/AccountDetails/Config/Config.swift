//
//  Config.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

public struct Config {
    
    let images: Images
    let sizes: Sizes
    let colors: Colors
    let fonts: Fonts
    
    public init(
        images: Images,
        sizes: Sizes,
        colors: Colors,
        fonts: Fonts
    ) {
        self.images = images
        self.sizes = sizes
        self.colors = colors
        self.fonts = fonts
    }
}

public extension Config {
    
    struct Images {
        
        let numberMasked: Image
        let cvvMasked: Image
        let number: Image
        let cvv: Image
        let checkOn: Image
        let checkOff: Image
        
        public init(
            numberMasked: Image,
            cvvMasked: Image,
            number: Image,
            cvv: Image,
            checkOn: Image,
            checkOff: Image
        ) {
            self.numberMasked = numberMasked
            self.cvvMasked = cvvMasked
            self.number = number
            self.cvv = cvv
            self.checkOn = checkOn
            self.checkOff = checkOff
        }
    }
}

public extension Config {
    
    struct Sizes {
        
        let icon: CGFloat
        
        public init(
            icon: CGFloat
        ) {
            self.icon = icon
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
        
        public init(
            image: Color,
            title: Color,
            subtitle: Color,
            fill: Color,
            checkBoxTitle: Color
        ) {
            self.image = image
            self.title = title
            self.subtitle = subtitle
            self.fill = fill
            self.checkBoxTitle = checkBoxTitle
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
