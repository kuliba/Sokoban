//
//  ProductDetailsReducer.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public final class ProductDetailsReducer {
    
    public init() {}
}

public extension ProductDetailsReducer {
 
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .appear:
            state.event = .appear
            
        case let .itemTapped(tap):
            switch tap {
            case let .longPress(valueForCopy, text):
                state.event = .itemTapped(.longPress(valueForCopy, text))
                
            case let .iconTap(itemId):
                state.event = .itemTapped(.iconTap(itemId))
            }
        }
        
        return (state, .none)
    }
}

public extension ProductDetailsReducer {
    
    typealias State = ProductDetailsState
    typealias Event = ProductDetailsEvent
    typealias Effect = ProductDetailsEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
