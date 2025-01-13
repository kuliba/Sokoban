//
//  NavigationBarConfig.swift
//  
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import SwiftUI

public struct NavigationBarConfig {
    
    let title: TextConfig
    let subTitle: TextConfig
    let colors: Colors
    let sizes: Sizes
    
    public init(
        title: TextConfig,
        subTitle: TextConfig,
        colors: Colors,
        sizes: Sizes
    ) {
        self.title = title
        self.subTitle = subTitle
        self.colors = colors
        self.sizes = sizes
    }
    
    public struct Colors {
        
        let foreground: Color
        let background: Color
        
        public init(foreground: Color, background: Color) {
            self.foreground = foreground
            self.background = background
        }
    }
    
    public struct Sizes {
        
        let heightBar: CGFloat
        let padding: CGFloat
        let widthBackButton: CGFloat
        
        public init(heightBar: CGFloat, padding: CGFloat, widthBackButton: CGFloat) {
            self.heightBar = heightBar
            self.padding = padding
            self.widthBackButton = widthBackButton
        }
    }
}
