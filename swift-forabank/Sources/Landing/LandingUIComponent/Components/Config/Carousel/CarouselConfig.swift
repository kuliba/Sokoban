//
//  CarouselConfig.swift
//
//
//  Created by Andryusina Nataly on 07.10.2024.
//

import Foundation

public extension UILanding.Carousel {
    
    struct Config {
        
        public let base: CarouselBase.Config
        
        public init(base: CarouselBase.Config) {
            self.base = base
        }
    }
}
