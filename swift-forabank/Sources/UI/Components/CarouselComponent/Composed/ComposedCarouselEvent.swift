//
//  ComposedCarouselEvent.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public enum ComposedCarouselEvent: Equatable {
    
    case carouselEvent(CarouselEvent)
    case selectorEvent(SelectorEvent)
}
