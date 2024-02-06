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
    
#warning("add tests")
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
            state.modal = nil
        case .showAlertChangePin:
            state.modal = nil
        case .showAlertCardGuardian:
            state.modal = nil
            effect = .delayAlert(.init(
                title: "showAlertCardGuardian",
                message: "",
                primaryButton: .init(
                    type: .cancel,
                    title: "Отмена",
                    event: .closeAlert)))
        case let .showAlert(alert):
            state.alert = alert
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
