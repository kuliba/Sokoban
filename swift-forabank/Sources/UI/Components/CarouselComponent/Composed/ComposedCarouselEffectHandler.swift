//
//  ComposedCarouselEffectHandler.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class ComposedCarouselEffectHandler {
    
    let carouselEffectHandler: CarouselEffectHandler
    let selectorEffectHandler: SelectorEffectHandler
    
    public init(
        carouselEffectHandler: CarouselEffectHandler,
        selectorEffectHandler: SelectorEffectHandler
    ) {
        self.carouselEffectHandler = carouselEffectHandler
        self.selectorEffectHandler = selectorEffectHandler
    }
}

public extension ComposedCarouselEffectHandler {
    
    typealias Dispatch = (ComposedCarouselEvent) -> Void
    
    func handleEffect(
        _ effect: ComposedCarouselEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .carouselEffect(_):
            break
        case .selectorEffect(_):
            break
        }
    }
}
