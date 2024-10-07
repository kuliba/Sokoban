//
//  CarouselBaseConfig.swift
//
//
//  Created by Andryusina Nataly on 05.10.2024.
//

import Foundation
import SwiftUI

public extension UILanding.Carousel.CarouselBase {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let paddings: Paddings
        let spacing: CGFloat
        let titleFont: Font
        
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
            titleFont: Font
        ){
            self.cornerRadius = cornerRadius
            self.paddings = paddings
            self.spacing = spacing
            self.titleFont = titleFont
        }
    }
}
