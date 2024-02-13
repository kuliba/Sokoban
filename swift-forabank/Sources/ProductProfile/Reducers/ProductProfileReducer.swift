//
//  ProductProfileReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import CardGuardianModule

public final class ProductProfileReducer {
    
    private let guardianReduce: GuardianReduce
    private let showOnMainReduce: ShowOnMainReduce
    
    public init(
        guardianReduce: @escaping GuardianReduce,
        showOnMainReduce: @escaping ShowOnMainReduce
    ) {
        self.guardianReduce = guardianReduce
        self.showOnMainReduce = showOnMainReduce
    }
}

public extension ProductProfileReducer {
    
#warning("add tests")
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .appear:
            state.status = .appear
        case let .cardGuardian(guardianEvent):
            (state, effect) = guardianReduce(state, guardianEvent)
        case let .showOnMain(showOnMainEvent):
            (state, effect) = showOnMainReduce(state, showOnMainEvent)
        case .changePin:
            state.status = .infligth
            effect = .changePin // ????
        }
        return (state, effect)
    }
}

public extension ProductProfileReducer {
    
    typealias GuardianReduce = (State, GuardianEvent) -> (State, Effect?)
    typealias ShowOnMainReduce = (State, ShowOnMainEvent) -> (State, Effect?)
    
    typealias State = ProductProfileState
    typealias Event = ProductProfileEvent
    typealias Effect = ProductProfileEffect
}

private extension ProductProfileReducer {
    
    func blockCard(
        _ state: State,
        _ card: Card
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.status = .infligth
        effect = .blockCard(card)
        
        return (state, effect)
    }
    
    func unblockCard(
        _ state: State,
        _ card: Card
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.status = .infligth
        effect = .unblockCard(card)
        
        return (state, effect)
    }
}
