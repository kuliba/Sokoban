//
//  DropDownTexts.swift
//  
//
//  Created by Andrew Kurdin on 2023-09-10.
//

import SwiftUI

public extension UILanding.List.DropDownTexts { 
    
    struct Config {
        
        public let fonts: Fonts
        public let colors: Colors
        public let paddings: Paddings
        public let heights: Heights
        public let backgroundColor: Color
        public let cornerRadius: CGFloat
        
        public struct Fonts {
            public let title: Font
            public let itemTitle: Font
            public let itemDescription: Font
            
            public init(title: Font, itemTitle: Font, itemDescription: Font) {
                self.title = title
                self.itemTitle = itemTitle
                self.itemDescription = itemDescription
            }
        }
        
        public struct Colors {
            public let title: Color
            public let itemTitle: Color
            public let itemDescription: Color
            
            public init(title: Color, itemTitle: Color, itemDescription: Color) {
                self.title = title
                self.itemTitle = itemTitle
                self.itemDescription = itemDescription
            }
        }
        
        public struct Heights {
            public let title: CGFloat
            public let item: CGFloat

            public init(title: CGFloat, item: CGFloat) {
                self.title = title
                self.item = item
            }
        }
        
        public struct Paddings {
            public let titleTop: CGFloat
            public let list: CGFloat
            public let itemVertical: CGFloat
            public let itemHorizontal: CGFloat
            
            public init(
                titleTop: CGFloat,
                list: CGFloat,
                itemVertical: CGFloat,
                itemHorizontal: CGFloat
            ) {
                self.titleTop = titleTop
                self.list = list
                self.itemVertical = itemVertical
                self.itemHorizontal = itemHorizontal
            }
        }
        
        public init(
            fonts: Fonts,
            colors: Colors,
            paddings: Paddings,
            heights: Heights,
            backgroundColor: Color,
            cornerRadius: CGFloat
        ) {
            self.fonts = fonts
            self.colors = colors
            self.paddings = paddings
            self.heights = heights
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
        }
    }
}
