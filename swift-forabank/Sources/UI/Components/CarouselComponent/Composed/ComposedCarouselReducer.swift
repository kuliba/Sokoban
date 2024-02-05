//
//  ComposedCarouselReducer.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class ComposedCarouselReducer {
    
    private let carouselReducer: CarouselReducer
    private let selectorReducer: SelectorReducer
    
    init(
        carouselReducer: CarouselReducer,
        selectorReducer: SelectorReducer
    ) {
        self.carouselReducer = carouselReducer
        self.selectorReducer = selectorReducer
    }
}

public extension ComposedCarouselReducer {
    
    func reduce(
        _ state: ComposedCarouselState,
        _ event: ComposedCarouselEvent
    ) -> (ComposedCarouselState, ComposedCarouselEffect?) {
        
        var state = state
        var effect: ComposedCarouselEffect?
        
        switch event {
        case .carouselEvent(_):
            break
        case .selectorEvent(_):
            break
        }
        
        return (state, effect)
    }
}
