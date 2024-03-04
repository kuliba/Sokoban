//
//  SliderReducer.swift
//  
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation

public final class SliderReducer {
    
    private let maxOffsetX: CGFloat
    
    public init(
        maxOffsetX: CGFloat
    ) {
        self.maxOffsetX = maxOffsetX
    }
}

public extension SliderReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Never?) {
        
        var state = state
        
        switch event {
            
        case let .drag(translationWidth):
            
            if translationWidth > 0 && translationWidth <= maxOffsetX {
                
                state = translationWidth
            }

        case let .dragEnded(value):
            
            if value > maxOffsetX/2 {
                 state = maxOffsetX
            } else {
                state = 0
            }
        }
        return (state, nil)
    }
}

public extension SliderReducer {
    
    typealias State = CGFloat
    typealias Event = SliderEvent
    
    typealias Reduce = (State, Event) -> (State, Never?)
}
