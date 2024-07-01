//
//  ListHorizontalRectangleLimitsReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import UIPrimitives

public final class ListHorizontalRectangleLimitsReducer {
    
    public init() {}
}

public extension ListHorizontalRectangleLimitsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?

        //TODO: add case, add tests
//        switch event {
//
//        case let .buttonTapped(info):
//            
//        }
        return (state, effect)
    }
}

public extension ListHorizontalRectangleLimitsReducer {
    
    typealias State = ListHorizontalRectangleLimitsState
    typealias Event = ListHorizontalRectangleLimitsEvent
    typealias Effect = ListHorizontalRectangleLimitsEffect
}
