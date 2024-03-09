//
//  CarouselComponentConfig.swift
//
//
//  Created by Disman Dmitry on 14.02.2024.
//

import SwiftUI
import Tagged

public struct CarouselComponentConfig {
    
    public let carouselConfig: CarouselConfig
    public let selectorConfig: SelectorConfig
    
    public init(
        carouselConfig: CarouselConfig,
        selectorConfig: SelectorConfig
    ) {
        self.carouselConfig = carouselConfig
        self.selectorConfig = selectorConfig
    }
}
