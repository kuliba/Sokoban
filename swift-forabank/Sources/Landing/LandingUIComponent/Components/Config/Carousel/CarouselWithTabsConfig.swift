//
//  CarouselWithTabsConfig.swift
//
//
//  Created by Andryusina Nataly on 09.10.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public extension UILanding.Carousel.CarouselWithTabs {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let paddings: Paddings
        let pageControls: PageControls
        let spacing: CGFloat
        let title: TextConfig
        let category: TextConfig

        public struct PageControls {
            
            let active: Color
            let inactive: Color
            let height: CGFloat
            
            public init(active: Color, inactive: Color, height: CGFloat) {
                self.active = active
                self.inactive = inactive
                self.height = height
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
        
        public init(
            category: TextConfig,
            cornerRadius: CGFloat,
            paddings: Paddings,
            pageControls: PageControls,
            spacing: CGFloat,
            title: TextConfig
        ){
            self.category = category
            self.cornerRadius = cornerRadius
            self.paddings = paddings
            self.pageControls = pageControls
            self.spacing = spacing
            self.title = title
        }
    }
}
