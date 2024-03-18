//
//  Config.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct Config {
    
    public let appearance: Appearance
    public let backView: BackView
    public let cardView: CardView
    public let fonts: Fonts
    public let sizes: Sizes
    public let colors: Colors
    public let copyImage: Image
    
    public init(
        appearance: Appearance,
        backView: BackView,
        cardView: CardView,
        fonts: Fonts,
        sizes: Sizes,
        colors: Colors,
        copyImage: Image
    ) {
        self.appearance = appearance
        self.backView = backView
        self.cardView = cardView
        self.fonts = fonts
        self.sizes = sizes
        self.colors = colors
        self.copyImage = copyImage
    }
}

public extension Config {
    
    struct BackView {
        
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
    
    struct CardView {
        
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
        public let checkView: CGSize
        public let checkViewImage: CGSize
        
        public init(
            paymentSystemIcon: CGSize,
            checkView: CGSize,
            checkViewImage: CGSize
        ) {
            self.paymentSystemIcon = paymentSystemIcon
            self.checkView = checkView
            self.checkViewImage = checkViewImage
        }
    }
    
    struct Colors {
        let foreground: Color
        let background: Color
        let rateFill: Color
        let rateForeground: Color
        
        public init(
            foreground: Color,
            background: Color,
            rateFill: Color,
            rateForeground: Color
        ) {
            self.foreground = foreground
            self.background = background
            self.rateFill = rateFill
            self.rateForeground = rateForeground
        }
    }
}
