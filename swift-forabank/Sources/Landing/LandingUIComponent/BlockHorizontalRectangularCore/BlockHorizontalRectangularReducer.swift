//
//  BlockHorizontalRectangularReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation
import UIPrimitives

public final class BlockHorizontalRectangularReducer {
    
    public init() {}
}

public extension BlockHorizontalRectangularReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?

        //TODO: add case, add tests
//        switch event {
//    case let .change(limit):
//        
//        if limit.value > maxSum {
//            state.warning = hint
//        } else {
//            state.warning = ""
//        }
//        state.value = "\(limit.value)"
//            
//        }
        
        return (state, effect)
    }
}

public extension BlockHorizontalRectangularReducer {
    
    typealias State = BlockHorizontalRectangularState
    typealias Event = BlockHorizontalRectangularEvent
    typealias Effect = BlockHorizontalRectangularEffect
}
