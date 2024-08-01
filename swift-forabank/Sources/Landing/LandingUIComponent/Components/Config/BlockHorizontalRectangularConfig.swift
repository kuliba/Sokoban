//
//  BlockHorizontalRectangularConfig.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import Foundation
import SwiftUI

public extension UILanding.BlockHorizontalRectangular {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let colors: Colors
        let sizes: Sizes
        let paddings: Paddings
        let spacing: CGFloat
        
        public struct Colors {
            
            let background: Color
            let divider: Color
            let title: Color
            let subtitle: Color
            let warning: Color
            
            public init(
                background: Color,
                divider: Color,
                title: Color,
                subtitle: Color,
                warning: Color
            ) {
                self.background = background
                self.divider = divider
                self.title = title
                self.subtitle = subtitle
                self.warning = warning
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
            
            let iconWidth: CGFloat
            let height: CGFloat
            let width: CGFloat
            
            public init(iconWidth: CGFloat, height: CGFloat, width: CGFloat) {
                self.iconWidth = iconWidth
                self.height = height
                self.width = width
            }
        }
        
        public init(
            colors: Colors,
            cornerRadius: CGFloat,
            sizes: Sizes,
            paddings: Paddings,
            spacing: CGFloat
        ){
            self.colors = colors
            self.cornerRadius = cornerRadius
            self.sizes = sizes
            self.paddings = paddings
            self.spacing = spacing
        }
    }
}
