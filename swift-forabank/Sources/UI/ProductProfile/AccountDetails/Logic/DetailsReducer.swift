//
//  DetailsReducer.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public final class DetailsReducer {
    
    public init() {}
}

public extension DetailsReducer {
 
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .appear:
            state.updateEvent(.appear)
            
        case let .itemTapped(tap):
            switch tap {
                
            case let .longPress(valueForCopy, text):
                state.updateEvent(.itemTapped(.longPress(valueForCopy, text)))
                
            case let .iconTap(itemId):
                state.updateEvent(.itemTapped(.iconTap(itemId)))
            }
        }
        return (state, .none)
    }
}

public extension DetailsReducer {
    
    typealias State = DetailsState
    typealias Event = DetailsEvent
    typealias Effect = DetailsEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
