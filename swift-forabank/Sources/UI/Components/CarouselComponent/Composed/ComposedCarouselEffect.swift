//
//  ComposedCarouselEffect.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public enum ComposedCarouselEffect: Equatable {
    
    case carouselEffect(CarouselEffect)
    case selectorEffect(SelectorEffect)
}
