//
//  ListHorizontalRectangleLimitsConfig.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import Foundation
import SwiftUI

public extension UILanding.List.HorizontalRectangleLimits {
    
    struct Config {
        
        let colors: Colors
        let cornerRadius: CGFloat
        let fonts: Fonts
        let paddings: Paddings
        let sizes: Sizes
        let spacing: CGFloat
        
        public struct Colors {
            
            let arc: Color
            let background: Color
            let divider: Color
            let title: Color
            let subtitle: Color
            
            public init(
                arc: Color,
                background: Color,
                divider: Color,
                title: Color,
                subtitle: Color
            ) {
                self.arc = arc
                self.background = background
                self.divider = divider
                self.title = title
                self.subtitle = subtitle
            }
        }
        
        public struct Fonts {
            
            let title: Font
            let subTitle: Font
            let limit: Font
            
            public init(title: Font, subTitle: Font, limit: Font) {
                self.title = title
                self.subTitle = subTitle
                self.limit = limit
            }
        }
        
        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }

        public struct Sizes {
            
            let height: CGFloat
            let icon: CGFloat
            let width: CGFloat
            
            public init(height: CGFloat, icon: CGFloat, width: CGFloat) {
                self.height = height
                self.icon = icon
                self.width = width
            }
        }
        
        public init(
            colors: Colors,
            cornerRadius: CGFloat,
            fonts: Fonts,
            paddings: Paddings,
            sizes: Sizes,
            spacing: CGFloat
        ) {
            self.colors = colors
            self.cornerRadius = cornerRadius
            self.fonts = fonts
            self.paddings = paddings
            self.sizes = sizes
            self.spacing = spacing
        }
    }
}
