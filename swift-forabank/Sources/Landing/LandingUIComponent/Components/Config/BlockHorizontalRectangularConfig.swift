//
//  BlockHorizontalRectangularConfig.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import Foundation

public extension UILanding.BlockHorizontalRectangular {
    
    struct Config {
        
        let cornerRadius: CGFloat
        let size: Size
        let paddings: Paddings
        let spacing: CGFloat
        
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
            let width: CGFloat
            
            public init(height: CGFloat, width: CGFloat) {
                self.height = height
                self.width = width
            }
        }
        
        public init(
            cornerRadius: CGFloat,
            size: Size,
            paddings: Paddings,
            spacing: CGFloat
        ){
            self.cornerRadius = cornerRadius
            self.size = size
            self.paddings = paddings
            self.spacing = spacing
        }
    }
}
