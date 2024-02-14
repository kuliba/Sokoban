//
//  ProductProfileNavigationProductProfileReducer.swift
//
//
//  Created by Andryusina Nataly on 14.02.2024.
//

import Foundation

public final class ProductProfileNavigationProductProfileReducer {
    
    public init(){}
}


public extension ProductProfileNavigationProductProfileReducer {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileEvent
    typealias Effect = ProductProfileNavigation.Effect
}

public extension ProductProfileNavigationProductProfileReducer {
    
#warning("add tests")
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
    }
}
