//
//  CarouselReducer.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class CarouselReducer {
    
    public init() { }
}

public extension CarouselReducer {
    
    func reduce(
        _ state: CarouselState,
        _ event: CarouselEvent
    ) -> (CarouselState, CarouselEffect?) {
        
        var state = state
        var effect: CarouselEffect?
        
        switch event {
            
        case .appear:
            break
        }
        
        return (state, effect)
    }
}
