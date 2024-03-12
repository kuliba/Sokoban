//
//  SheetConfig.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import SwiftUI

public struct SheetConfig {
    
    let image: Image
    let paddings: Paddings
    let buttonSizes: Sizes
    let imageSizes: Sizes
    let colors: Colors
    let fonts: Fonts
    
    public init(
        image: Image,
        paddings: Paddings,
        imageSizes: Sizes,
        buttonSizes: Sizes,
        colors: Colors,
        fonts: Fonts
    ) {
        self.image = image
        self.paddings = paddings
        self.imageSizes = imageSizes
        self.buttonSizes = buttonSizes
        self.colors = colors
        self.fonts = fonts
    }
}

public extension SheetConfig {
    
    struct Sizes {
        
        let height: CGFloat
        let cornerRadius: CGFloat
        
        public init(
            height: CGFloat,
            cornerRadius: CGFloat
        ) {
            self.height = height
            self.cornerRadius = cornerRadius
        }
    }
}

public extension SheetConfig {
    
    struct Paddings {
        
        let horizontal: CGFloat
        let topTitle: CGFloat
        let topSubtitle: CGFloat
        
        public init(
            horizontal: CGFloat,
            topTitle: CGFloat,
            topSubtitle: CGFloat
        ) {
            self.horizontal = horizontal
            self.topTitle = topTitle
            self.topSubtitle = topSubtitle
        }
    }
}

public extension SheetConfig {
    
    struct Colors {
        
        let background: Color
        let foreground: Color
        let subtitle: Color
        
        public init(
            background: Color,
            foreground: Color,
            subtitle: Color
        ) {
            self.background = background
            self.foreground = foreground
            self.subtitle = subtitle
        }
    }
}

public extension SheetConfig {
    
    struct Fonts {
        let title: Font
        let subtitle: Font
        let button: Font
        
        public init(
            title: Font,
            subtitle: Font,
            button: Font
        ) {
            self.title = title
            self.subtitle = subtitle
            self.button = button
        }
    }
}
