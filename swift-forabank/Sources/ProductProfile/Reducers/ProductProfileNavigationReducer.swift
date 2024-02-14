//
//  ProductProfileNavigationReducer.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation
import UIPrimitives
import CardGuardianModule

public final class ProductProfileNavigationReducer {
        
    public init() {}
}

public extension ProductProfileNavigationReducer {
    
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
        case .create:
            state.modal = nil
            effect = .create
        case .dismissDestination:
            state.modal = nil
        case let .showAlert(alert):
            state.alert = alert
        case let .open(modal):
            state.modal = .init(modal.viewModel, modal.cancellable)
        case let .cardGuardianInput(cardGuardianInput):
            state.alert = nil
            (state, effect) = reduce(state, cardGuardianInput)
        case let .alertInput(event):
            state.alert = nil
            (state, effect) = reduce(state, event)
        }
        return (state, effect)
    }
}

public extension ProductProfileNavigationReducer {
    
    typealias State = ProductProfileNavigation.State
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
}

private extension ProductProfileNavigationReducer {
    
    func reduce(
        _ state: State,
        _ cardGuardianInput: CardGuardianStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch cardGuardianInput {
        
        case .appear:
            break
        case let .buttonTapped(tap):
            switch tap {
                
            case let .toggleLock(card):
                state.modal = nil
                state.alert = nil
                effect = .delayAlert(Alerts.alertBlockCard(card))
            case let .changePin(card):
                state.modal = nil
                state.alert = nil
                effect = .sendRequest(.changePin(card))
            case let .visibilityOnMain(product):
                state.modal = nil
                effect = .sendRequest(.visibilityOnMain(product))
            }
        }
        
        return (state, effect)
    }
}

private extension ProductProfileNavigationReducer {
    
    func reduce(
        _ state: State,
        _ alertInput: ProductProfileEvent
    ) -> (State, Effect?) {
        
        return (state, .sendRequest(alertInput))
    }
}
