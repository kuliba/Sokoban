//
//  Config.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct Config {
    
    public let appearance: Appearance
    public let back: Back
    public let front: Front
    public let fonts: Fonts
    public let sizes: Sizes
    public let colors: Colors
    public let images: Images
    
    public init(
        appearance: Appearance,
        back: Back,
        front: Front,
        fonts: Fonts,
        sizes: Sizes,
        colors: Colors,
        images: Images
    ) {
        self.appearance = appearance
        self.back = back
        self.front = front
        self.fonts = fonts
        self.sizes = sizes
        self.colors = colors
        self.images = images
    }
}

public extension Config {
    
    struct Back {
        
        public let headerLeadingPadding: CGFloat
        public let headerTopPadding: CGFloat
        public let headerTrailingPadding: CGFloat
        
        public init(
            headerLeadingPadding: CGFloat,
            headerTopPadding: CGFloat,
            headerTrailingPadding: CGFloat
        ) {
            self.headerLeadingPadding = headerLeadingPadding
            self.headerTopPadding = headerTopPadding
            self.headerTrailingPadding = headerTrailingPadding
        }
    }
    
    struct Front {
        
        public let headerLeadingPadding: CGFloat
        public let headerTopPadding: CGFloat
        public let nameSpacing: CGFloat
        public let cardPadding: CGFloat
        public let cornerRadius: CGFloat
        public let checkPadding: CGFloat
        
        public init(
            headerLeadingPadding: CGFloat,
            headerTopPadding: CGFloat,
            nameSpacing: CGFloat,
            cardPadding: CGFloat,
            cornerRadius: CGFloat,
            checkPadding: CGFloat
        ) {
            self.headerLeadingPadding = headerLeadingPadding
            self.headerTopPadding = headerTopPadding
            self.nameSpacing = nameSpacing
            self.cardPadding = cardPadding
            self.cornerRadius = cornerRadius
            self.checkPadding = checkPadding
        }
    }
    
    struct Fonts {
        
        public let card: Font
        public let header: Font
        public let footer: Font
        public let number: Font
        public let rate: Font
        
        public init(
            card: Font,
            header: Font,
            footer: Font,
            number: Font,
            rate: Font
        ) {
            self.card = card
            self.header = header
            self.footer = footer
            self.number = number
            self.rate = rate
        }
    }
    
    struct Sizes {
        
        public let paymentSystemIcon: CGSize
        public let checkViewImage: CGSize
        
        public init(
            paymentSystemIcon: CGSize,
            checkViewImage: CGSize
        ) {
            self.paymentSystemIcon = paymentSystemIcon
            self.checkViewImage = checkViewImage
        }
    }
    
    struct Colors {
        let foreground: Color
        let background: Color
        let rateFill: Color
        let rateForeground: Color
        let checkForeground: Color
        
        public init(
            foreground: Color,
            background: Color,
            rateFill: Color,
            rateForeground: Color,
            checkForeground: Color
        ) {
            self.foreground = foreground
            self.background = background
            self.rateFill = rateFill
            self.rateForeground = rateForeground
            self.checkForeground = checkForeground
        }
    }
    
    struct Images {
        
        public let copy: Image
        public let check: Image

        public init(copy: Image, check: Image) {
            self.copy = copy
            self.check = check
        }
    }
}
