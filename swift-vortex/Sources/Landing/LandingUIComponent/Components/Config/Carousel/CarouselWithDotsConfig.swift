//
//  CarouselWithDotsConfig.swift
//
//
//  Created by Andryusina Nataly on 05.10.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public extension UILanding.Carousel.CarouselWithDots {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let paddings: Paddings
        let pageControls: PageControls
        let spacing: CGFloat
        let title: TextConfig
        
        public struct PageControls {
            
            let active: Color
            let inactive: Color
            let widthAndHeight: CGFloat
            
            public init(active: Color, inactive: Color, widthAndHeight: CGFloat) {
                self.active = active
                self.inactive = inactive
                self.widthAndHeight = widthAndHeight
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
            cornerRadius: CGFloat,
            paddings: Paddings,
            pageControls: PageControls,
            spacing: CGFloat,
            title: TextConfig
        ){
            self.cornerRadius = cornerRadius
            self.paddings = paddings
            self.pageControls = pageControls
            self.spacing = spacing
            self.title = title
        }
    }
}
