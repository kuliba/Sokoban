//
//  CarouselComponentConfig.swift
//
//
//  Created by Disman Dmitry on 14.02.2024.
//

import SwiftUI
import Tagged

public struct CarouselComponentConfig {
    
    public let carousel: CarouselConfig
    public let selector: SelectorConfig
    
    public init(
        carousel: CarouselConfig,
        selector: SelectorConfig
    ) {
        self.carousel = carousel
        self.selector = selector
    }
}
