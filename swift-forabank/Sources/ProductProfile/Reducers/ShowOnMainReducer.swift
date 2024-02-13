//
//  ShowOnMainReducer.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

public final class ShowOnMainReducer {
    
    public init() {}
}

public extension ShowOnMainReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .showOnMain(product):
            (state, effect) = showOnMain(state, product)
        case let .hideFromMain(product):
            (state, effect) = hideFromMain(state, product)
        }
        
        return (state, effect)
    }
}

public extension ShowOnMainReducer {
    
    typealias State = ProductProfileState
    typealias Event = ShowOnMainEvent
    typealias Effect = ProductProfileEffect
}

private extension ShowOnMainReducer {
    
    func showOnMain(
        _ state: State,
        _ product: Product
    ) -> (State, Effect?) {
                
        var state = state
        var effect: Effect?
        
        state.status = .infligth
        effect = .showOnMain(product)
        
        return (state, effect)
    }
    
    func hideFromMain(
        _ state: State,
        _ product: Product
    ) -> (State, Effect?) {
                
        var state = state
        var effect: Effect?
        
        state.status = .infligth
        
        effect = .hideFromMain(product)
        
        return (state, effect)
    }
}
