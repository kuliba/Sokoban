//
//  CarouselBaseConfig.swift
//
//
//  Created by Andryusina Nataly on 05.10.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public extension UILanding.Carousel.CarouselBase {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let paddings: Paddings
        let spacing: CGFloat
        let title: TextConfig
        
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
            spacing: CGFloat,
            title: TextConfig
        ){
            self.cornerRadius = cornerRadius
            self.paddings = paddings
            self.spacing = spacing
            self.title = title
        }
    }
}
