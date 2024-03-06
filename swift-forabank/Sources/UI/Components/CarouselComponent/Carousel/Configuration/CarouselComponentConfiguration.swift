//
//  CarouselComponentConfiguration.swift
//
//
//  Created by Disman Dmitry on 14.02.2024.
//

import SwiftUI
import Tagged

public struct CarouselComponentConfiguration {
    
    public let carouselConfiguration: CarouselConfiguration
    public let selectorConfiguration: SelectorConfiguration
    
    public init(
        carouselConfiguration: CarouselConfiguration,
        selectorConfiguration: SelectorConfiguration
    ) {
        self.carouselConfiguration = carouselConfiguration
        self.selectorConfiguration = selectorConfiguration
    }
}
