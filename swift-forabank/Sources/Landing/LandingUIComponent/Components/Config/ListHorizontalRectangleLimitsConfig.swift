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
        let paddings: Paddings
        let size: Size
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
        
        public struct Paddings {
            
            let horizontal: CGFloat
            let vertical: CGFloat
            
            public init(horizontal: CGFloat, vertical: CGFloat) {
                self.horizontal = horizontal
                self.vertical = vertical
            }
        }

        public struct Size {
            
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
            paddings: Paddings,
            size: Size,
            spacing: CGFloat
        ) {
            self.colors = colors
            self.cornerRadius = cornerRadius
            self.paddings = paddings
            self.size = size
            self.spacing = spacing
        }
    }
}
