//
//  ComposedCarouselState.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public struct ComposedCarouselState: Equatable {
    
    var carouselCarouselState: CarouselState
    var selectorCarouselState: SelectorState
}
