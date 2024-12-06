//
//  DropDownTextListConfig.swift
//  
//
//  Created by Valentin Ozerov on 06.12.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public struct DropDownTextListConfig {
    
    public let cornerRadius: CGFloat
    public let chevronDownImage: Image
    public let layouts: Layouts
    public let colors: Colors
    public let fonts: Fonts

    public init(
        cornerRadius: CGFloat,
        chevronDownImage: Image,
        layouts: Layouts,
        colors: Colors,
        fonts: Fonts
    ) {
        self.cornerRadius = cornerRadius
        self.chevronDownImage = chevronDownImage
        self.layouts = layouts
        self.colors = colors
        self.fonts = fonts
    }
    
    public struct Layouts {
        
        public let topPadding: CGFloat?
        public let bottomPadding: CGFloat?
        public let horizontalPadding: CGFloat?
        public let verticalPadding: CGFloat?
        public let itemHeight: CGFloat?
        
        public init(
            topPadding: CGFloat? = nil,
            bottomPadding: CGFloat? = nil,
            horizontalPadding: CGFloat? = nil,
            verticalPadding: CGFloat? = nil,
            itemHeight: CGFloat?
        ) {
            
            self.topPadding = topPadding
            self.bottomPadding = bottomPadding
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.itemHeight = itemHeight
        }
    }
    
    public struct Colors {
        
        public let divider: Color
        public let background: Color
        
        public init(divider: Color, background: Color) {
            self.divider = divider
            self.background = background
        }
    }
    
    public struct Fonts {
        
        public let title: TextConfig
        public let itemTitle: TextConfig
        public let itemSubtitle: TextConfig
        
        public init(title: TextConfig, itemTitle: TextConfig, itemSubtitle: TextConfig) {
            self.title = title
            self.itemTitle = itemTitle
            self.itemSubtitle = itemSubtitle
        }
    }
}
