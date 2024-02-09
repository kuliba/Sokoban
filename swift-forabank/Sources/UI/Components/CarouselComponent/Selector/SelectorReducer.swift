//
//  SelectorReducer.swift
//  
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class SelectorReducer {
    
    public init() { }
}

public extension SelectorReducer {
    
    func reduce(
        _ state: SelectorState,
        _ event: SelectorEvent
    ) -> (SelectorState, SelectorEffect?) {
        
        var state = state
        var effect: SelectorEffect?
        
        switch event {
            
        case .appear:
            break
        }
        
        return (state, effect)
    }
}
