//
//  CarouselBaseState.swift
//
//
//  Created by Andryusina Nataly on 05.10.2024.
//

import Foundation

public struct CarouselBaseState: Equatable {
    
    let data: UILanding.Carousel.CarouselBase
    
    public init(
        data: UILanding.Carousel.CarouselBase
    ) {
        self.data = data
    }
}
