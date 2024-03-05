//
//  CarouselReducer.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class CarouselReducer {
    
    public typealias State = CarouselState
    public typealias Event = CarouselEvent
    public typealias Effect = CarouselEffect
    
    public init() { }
}

extension CarouselReducer {
    
    public func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .toggle(id: groupID, screenwidth: screenWidth, xOffset: xOffset):
            break
            
        case let .scrolledTo(groupID):
            state.selectedProductType = groupID
            state.selector.selected = groupID
            
        case let .select(productType, delay):
            effect = .scrollTo(productType, delay)
        
        case let .didScrollTo(xOffset):
            break
            
        case let .update(products):
            state = .init(products: products)
        }
        
        return (state, effect)
    }
}
