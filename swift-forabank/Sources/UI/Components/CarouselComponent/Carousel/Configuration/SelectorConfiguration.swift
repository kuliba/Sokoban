//
//  SelectorConfiguration.swift
//  
//
//  Created by Disman Dmitry on 05.03.2024.
//

import SwiftUI
import Tagged

public struct SelectorConfiguration {
    
    public let appearance: Appearance
    public let style: Style
    public let carouselSizing: CarouselConfiguration.Sizing

    public init(
        appearance: Appearance = .template,
        style: Style,
        carouselSizing: CarouselConfiguration.Sizing
    ) {
        self.appearance = appearance
        self.style = style
        self.carouselSizing = carouselSizing
    }
    
    public enum Appearance {
        
        case template
        case products
        case productsSmall
        
        var itemSpacing: CGFloat {
            
            switch self {
            case .template:
                return 8
            case .products, .productsSmall:
                return 8
            }
        }
    }
}

public extension SelectorConfiguration {
    
    struct Style {
        
        public let colors: Colors
        public let fonts: Fonts
        
        public init(
            colors: Colors,
            fonts: Fonts
        ) {
            self.colors = colors
            self.fonts = fonts
        }
        
        public struct Colors {
            
            let optionTextForeground: Colors
            let optionShapeForeground: Colors
            
            public init(
                optionTextForeground: Colors,
                optionShapeForeground: Colors
            ) {
                self.optionTextForeground = optionTextForeground
                self.optionShapeForeground = optionShapeForeground
            }
            
            public struct Colors: Hashable {
                let `default`: Color
                let selected: Color
                
                public init(default: Color, selected: Color) {
                    self.default = `default`
                    self.selected = selected
                }
            }
        }
        
        public struct Fonts {
            
            let optionTextFont: Font
            
            public init(
                optionTextFont: Font
            ) {
                self.optionTextFont = optionTextFont
            }
        }
    }
}
