//
//  Appearance.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct Appearance {
    
    public var background: Background
    public let colors: Colors
    public var opacity: Double
    public let size: Size
    public let style: Style
    
    public init(
        background: Background,
        colors: Colors,
        opacity: Double = 1,
        size: Size = .normal,
        style: Style = .main
    ) {
        self.background = background
        self.colors = colors
        self.opacity = opacity
        self.size = size
        self.style = style
    }

    public enum Size {
        
        case large
        case normal
        case small
    }
    
    public enum Style {
        
        case main
        case profile
    }
    
    public enum NameOfCreditProduct {
        
        case productView
        case myProductsSectionItem
        case cardTitle
    }
    
    public struct Background {
        
        public let color: Color
        public let image: Image?
        
        public init(
            color: Color,
            image: Image?
        ) {
            self.color = color
            self.image = image
        }
    }
    
    public struct Colors {
        public let text: Color
        public let checkBackground: Color
        
        public init(text: Color, checkBackground: Color) {
            self.text = text
            self.checkBackground = checkBackground
        }
    }
}
