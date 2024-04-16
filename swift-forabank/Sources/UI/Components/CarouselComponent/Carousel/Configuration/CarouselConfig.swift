//
//  CarouselConfig.swift
//
//
//  Created by Disman Dmitry on 05.03.2024.
//

import SwiftUI

public struct CarouselConfig {
    
    public let item: ItemConfig
    public let group: GroupConfig
    
    public let spoilerImage: Image
    public let separatorForeground: Color
    
    public let productDimensions: ProductDimensions
    
    public init(
        item: ItemConfig,
        group: GroupConfig,
        spoilerImage: Image,
        separatorForeground: Color,
        productDimensions: ProductDimensions
    ) {
        self.item = item
        self.group = group
        self.spoilerImage = spoilerImage
        self.separatorForeground = separatorForeground
        self.productDimensions = productDimensions
    }
    
    public struct ProductDimensions: Equatable {
        
        let spacing: CGFloat
        let frameHeight: CGFloat
        let bottomPadding: CGFloat
        let sizes: Sizes
        
        struct Sizes: Equatable {
            
            let product: CGSize
            let productShadow: CGSize
            let new: CGSize
            let button: CGSize
            let separator: CGSize
        }
    }
}

public extension CarouselConfig {
    
    struct ItemConfig {
        
        let spacing: CGFloat
        let horizontalPadding: CGFloat
        
        public init(
            spacing: CGFloat,
            horizontalPadding: CGFloat
        ) {
            self.spacing = spacing
            self.horizontalPadding = horizontalPadding
        }
    }
    
    struct GroupConfig {
        
        let spacing: CGFloat
        let buttonFont: Font
        let shadowForeground: Color
        let buttonForegroundPrimary: Color
        let buttonForegroundSecondary: Color
        let buttonIconForeground: Color
        
        public init(
            spacing: CGFloat,
            buttonFont: Font,
            shadowForeground: Color,
            buttonForegroundPrimary: Color,
            buttonForegroundSecondary: Color,
            buttonIconForeground: Color
        ) {
            self.spacing = spacing
            self.buttonFont = buttonFont
            self.shadowForeground = shadowForeground
            self.buttonForegroundPrimary = buttonForegroundPrimary
            self.buttonForegroundSecondary = buttonForegroundSecondary
            self.buttonIconForeground = buttonIconForeground
        }
    }
}

public extension CarouselConfig.ProductDimensions {
    
    static let regular: Self = .init(
        spacing: 8,
        frameHeight: 127,
        bottomPadding: 0,
        sizes: .init(
            product:       .init(width: 164, height: 104),
            productShadow: .init(width: 120, height: 104),
            new:           .init(width: 112, height: 104),
            button:        .init(width:  48, height: 104),
            separator:     .init(width:   1, height: 48)
        )
    )
    static let small: Self = .init(
        spacing: 8,
        frameHeight: 92,
        bottomPadding: 20,
        sizes: .init(
            product:       .init(width: 112, height: 72),
            productShadow: .init(width:  62, height: 64),
            new:           .init(width: 112, height: 72),
            button:        .init(width:  40, height: 72),
            separator:     .init(width:   1, height: 48)
        )
    )
}
