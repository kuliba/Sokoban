//
//  ProductProfileNavigationStateManager.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation

public struct ProductProfileNavigationStateManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
    
    public init(
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
    }
}

public extension ProductProfileNavigationStateManager {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    typealias Dispatch = (Event) -> Void

    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}
