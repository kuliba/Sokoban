//
//  Appearance.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct Appearance {
    
    public let textColor: Color
    public var background: Background
    public var opacity: Double
    public let size: Size
    public let style: Style
    
    public init(
        textColor: Color,
        background: Background,
        opacity: Double = 1,
        size: Size = .normal,
        style: Style = .main
    ) {
        self.textColor = textColor
        self.background = background
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
        
        case navigationTitle
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
}
