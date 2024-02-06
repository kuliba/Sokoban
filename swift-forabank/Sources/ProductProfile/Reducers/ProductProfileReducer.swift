//
//  ProductProfileReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation

public final class ProductProfileReducer {
    
    public init() {}
}

public extension ProductProfileReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?

        switch event {
        case .closeAlert:
            state.alert = nil
        case .openCardGuardianPanel:
            print("navigation openCardGuardianPanel")
        case .dismissDestination:
            state.destination = nil
        case .dismissDestinationAndShowAlertChangePin:
            state.destination = nil
            effect = .showAlertChangePin
        case .dismissDestinationAndShowAlertCardGuardian:
            state.destination = nil
            effect = .showAlertCardGuardian
        }
        return (state, effect)
    }
}

public extension ProductProfileReducer {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Reduce = (State, Event) -> (State, Effect?)
}
