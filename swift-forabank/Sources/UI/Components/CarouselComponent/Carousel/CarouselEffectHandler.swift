//
//  CarouselEffectHandler.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel
import Foundation

public final class CarouselEffectHandler {
    
    public init() { }
}

extension CarouselEffectHandler: EffectHandler {
    
    public func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .scrollTo(let id, let timeInterval):
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: {
                
                dispatch(.scrolledTo(id))
            })
        }
    }
}

public extension CarouselEffectHandler {
    
    typealias Effect = CarouselEffect
    typealias Event = CarouselEvent
    typealias Dispatch = (Event) -> Void
}
