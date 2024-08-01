//
//  SliderConfig.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

public struct SliderConfig {
    
    let colors: Colors
    let items: Items
    
    let font: Font
    
    let sizes: Sizes
          
    public struct Colors {
        
        let backgroundColor: Color
        let foregroundColor: Color
        let thumbIconColor: Color
        
        public init(backgroundColor: Color, foregroundColor: Color, thumbIconColor: Color) {
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.thumbIconColor = thumbIconColor
        }
    }
    
    public struct Item {
        
        let icon: Image
        let title: String
        
        public init(
            icon: Image,
            title: String
        ) {
            self.icon = icon
            self.title = title
        }
    }
    
    public struct Items {
        
        let notActivated: Item
        let confirmingActivation: Item
        let activating: Item
        let activated: Item
        
        public init(
            notActivated: Item,
            confirmingActivation: Item,
            activating: Item,
            activated: Item
        ) {
            self.notActivated = notActivated
            self.confirmingActivation = confirmingActivation
            self.activating = activating
            self.activated = activated
        }
    }
    
    public struct Sizes {
        
        let totalWidth: CGFloat
        let thumbWidth: CGFloat
        let thumbPadding: CGFloat
        
        public init(
            totalWidth: CGFloat = 167,
            thumbWidth: CGFloat = 40,
            thumbPadding: CGFloat = 4
        ) {
            self.totalWidth = totalWidth
            self.thumbWidth = thumbWidth
            self.thumbPadding = thumbPadding
        }
    }
    
    public init(
        colors: Colors,
        items: Items,
        sizes: Sizes,
        font: Font
    ) {
        self.colors = colors
        self.items = items
        self.sizes = sizes
        self.font = font
    }
    
    public var maxOffsetX: CGFloat { sizes.totalWidth - (sizes.thumbWidth + sizes.thumbPadding * 2) }
}
