//
//  CarouselConfiguration.swift
//  
//
//  Created by Disman Dmitry on 05.03.2024.
//

import SwiftUI

public struct CarouselConfiguration {
    
    public let style: Style
    public let sizing: Sizing
    public let productDimensions: ProductDimensions

    public init(
        style: Style,
        sizing: Sizing = .regular,
        productDimensions: ProductDimensions
    ) {
        self.style = style
        self.sizing = sizing
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

public extension CarouselConfiguration {
    
    enum Sizing {
        
        case regular
        case small
        
        var itemSpacing: CGFloat {
            
            switch self {
            case .regular, .small:
                return 13
            }
        }
        
        var productHorizontalPadding: CGFloat {
            
            switch self {
            case .regular:
                return 20
            case .small:
                return 12
            }
        }
        
        var productGroupSpacing: CGFloat {
            
            switch self {
            case .regular, .small:
                return 8
            }
        }
        
        var selectorOptionsFrameHeight: CGFloat? {
            
            switch self {
            case .regular:
                return 24
            case .small:
                return nil
            }
        }
    }
    
    struct Style {
        
        public let colors: Colors
        public let fonts: Fonts
        public let images: Images
        
        public init(
            colors: Colors,
            fonts: Fonts,
            images: Images
        ) {
            self.colors = colors
            self.fonts = fonts
            self.images = images
        }
        
        public struct Colors {
            
            let groupShadowForeground: Color
            let groupButtonForegroundPrimary: Color
            let groupButtonForegroundSecondary: Color
            let groupButtonIconForeground: Color
            let separatorForeground: Color
            
            public init(
                groupShadowForeground: Color,
                groupButtonForegroundPrimary: Color,
                groupButtonForegroundSecondary: Color,
                groupButtonIconForeground: Color,
                separatorForeground: Color
            ) {
                self.groupShadowForeground = groupShadowForeground
                self.groupButtonForegroundPrimary = groupButtonForegroundPrimary
                self.groupButtonForegroundSecondary = groupButtonForegroundSecondary
                self.groupButtonIconForeground = groupButtonIconForeground
                self.separatorForeground = separatorForeground
            }
        }
        
        public struct Fonts {
            
            let groupButton: Font
            
            public init(groupButton: Font) {
                self.groupButton = groupButton
            }
        }
        
        public struct Images {
            
            let spoilerImage: Image
            
            public init(spoilerImage: Image) {
                self.spoilerImage = spoilerImage
            }
        }
    }
}

public extension CarouselConfiguration.ProductDimensions {
    
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
