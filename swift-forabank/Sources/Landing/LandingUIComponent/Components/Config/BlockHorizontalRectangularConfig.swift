//
//  BlockHorizontalRectangularConfig.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public extension UILanding.BlockHorizontalRectangular {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let colors: Colors
        let limitConfig: LimitConfig
        let titleConfig: TextConfig
        let subtitleConfig: TextConfig
        let limitTitleConfig: TextConfig
        let sizes: Sizes
        let paddings: Paddings
        let spacing: CGFloat
        
        public struct Colors {
            
            let background: Color
            let divider: Color
            let warning: Color
            
            public init(
                background: Color,
                divider: Color,
                warning: Color
            ) {
                self.background = background
                self.divider = divider
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
            cornerRadius: CGFloat,
            colors: Colors,
            limitConfig: LimitConfig,
            titleConfig: TextConfig,
            subtitleConfig: TextConfig,
            limitTitleConfig: TextConfig,
            sizes: Sizes,
            paddings: Paddings,
            spacing: CGFloat
        ) {
            self.cornerRadius = cornerRadius
            self.colors = colors
            self.limitConfig = limitConfig
            self.titleConfig = titleConfig
            self.subtitleConfig = subtitleConfig
            self.limitTitleConfig = limitTitleConfig
            self.sizes = sizes
            self.paddings = paddings
            self.spacing = spacing
        }
    }
}
