//
//  ProductDetailsSheetReducer.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import Foundation

public final class ProductDetailsSheetReducer {
    
    public init() {}
}

public extension ProductDetailsSheetReducer {
 
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .appear:
            state.event = .appear
            
        case let .buttonTapped(tap):
            switch tap {
                
            case .sendAll:
                state.event = .buttonTapped(.sendAll)
                
            case .sendSelect:
                state.event = .buttonTapped(.sendSelect)
            }
        }
        return (state, .none)
    }
}

public extension ProductDetailsSheetReducer {
    
    typealias State = ProductDetailsSheetState
    typealias Event = ProductDetailsSheetEvent
    typealias Effect = ProductDetailsSheetEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
