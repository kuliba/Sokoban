//
//  ListVerticalRoundImageConfig.swift
//  NewComponents
//
//  Created by Andrew Kurdin on 18.09.2023.
//

import SwiftUI


public extension UILanding.List.VerticalRoundImage {
    
    struct Config {
        
        public let padding: Paddings
        public let title: Title
        public let divider: Color
        public let spacings: Spacings
        public let item: ListItem
        public let listVerticalPadding: CGFloat
        public let componentSettings: ComponentSettings
        public let buttonSettings: ButtonSettings
        
        public struct Paddings {
            
            public let horizontal: CGFloat
            public let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }
        
        public struct Title {
            
            public let font: Font
            public let color: Color
            public let paddingHorizontal: CGFloat
            public let paddingTop: CGFloat
            
            public init(font: Font, color: Color, paddingHorizontal: CGFloat, paddingTop: CGFloat) {
                self.font = font
                self.color = color
                self.paddingHorizontal = paddingHorizontal
                self.paddingTop = paddingTop
            }
        }
        
        public struct Spacings {
            
            public let lazyVstack: CGFloat
            public let itemHstack: CGFloat
            public let buttonHStack: CGFloat
            public let itemVStackBetweenTitleSubtitle: CGFloat
            
            public init(lazyVstack: CGFloat, itemHstack: CGFloat, buttonHStack: CGFloat, itemVStackBetweenTitleSubtitle: CGFloat) {
                self.lazyVstack = lazyVstack
                self.itemHstack = itemHstack
                self.buttonHStack = buttonHStack
                self.itemVStackBetweenTitleSubtitle = itemVStackBetweenTitleSubtitle
            }
        }
        
        public struct ListItem {
            
            public let imageWidthHeight: CGFloat
            public let hstackAlignment: VerticalAlignment
            public let font: Fonts
            public let color: Colors
            public let padding: Paddings
            
            public struct Fonts {
                
                public let title: Font
                public let titleWithOutSubtitle: Font
                public let subtitle: Font
                
                public init(title: Font, titleWithOutSubtitle: Font, subtitle: Font) {
                    self.title = title
                    self.titleWithOutSubtitle = titleWithOutSubtitle
                    self.subtitle = subtitle
                }
            }
            
            public struct Colors {
                
                public let title: Color
                public let subtitle: Color
                
                public init(title: Color, subtitle: Color) {
                    self.title = title
                    self.subtitle = subtitle
                }
            }
            
            public init(imageWidthHeight: CGFloat, hstackAlignment: VerticalAlignment, font: Fonts, color: Colors, padding: Paddings) {
                self.imageWidthHeight = imageWidthHeight
                self.hstackAlignment = hstackAlignment
                self.font = font
                self.color = color
                self.padding = padding
            }
        }
        
        public struct ButtonSettings {
            
            public let circleFill: Color
            public let circleWidthHeight: CGFloat
            public let ellipsisForegroundColor: Color
            public let text: Text
            public let padding: Paddings
            
            public struct Text {
                
                public let font: Font
                public let color: Color
                
                public init(font: Font, color: Color) {
                    self.font = font
                    self.color = color
                }
            }
            
            public init(circleFill: Color, circleWidthHeight: CGFloat, ellipsisForegroundColor: Color, text: Text, padding: Paddings) {
                self.circleFill = circleFill
                self.circleWidthHeight = circleWidthHeight
                self.ellipsisForegroundColor = ellipsisForegroundColor
                self.text = text
                self.padding = padding
            }
        }
        
        public struct ComponentSettings {
            public let background: Color
            public let cornerRadius: CGFloat
            
            public init(background: Color, cornerRadius: CGFloat) {
                self.background = background
                self.cornerRadius = cornerRadius
            }
        }
        
        public init(padding: Paddings, title: Title, divider: Color, spacings: Spacings, item: ListItem, listVerticalPadding: CGFloat, componentSettings: ComponentSettings, buttonSettings: ButtonSettings) {
            self.padding = padding
            self.title = title
            self.divider = divider
            self.spacings = spacings
            self.item = item
            self.listVerticalPadding = listVerticalPadding
            self.componentSettings = componentSettings
            self.buttonSettings = buttonSettings
        }
    }
}
