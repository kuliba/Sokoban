//
//  BlockHorizontalRectangularReducer.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import Foundation

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
        
        switch event {
        case let .edit(limit):
            state.newValues.updateOrAddLimit(limit)
            
        case let .save(limits):
            effect = .saveLimit(limits)
        }
        return (state, effect)
    }
}

public extension BlockHorizontalRectangularReducer {
    
    typealias State = BlockHorizontalRectangularState
    typealias Event = BlockHorizontalRectangularEvent
    typealias Effect = BlockHorizontalRectangularEffect
}

extension Array where Element == BlockHorizontalRectangularEvent.Limit {
    
    func firstIndex(matching id: String) -> Index? {
        
        firstIndex(where: { $0.id == id} )
    }
    
    mutating func updateOrAddLimit(_ newValue: BlockHorizontalRectangularEvent.Limit) {
        
        if let index = firstIndex(matching: newValue.id) {
            
            remove(at: index)
        }
        append(newValue)
    }
}
