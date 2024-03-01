//
//  ProductProfileNavigationReducer.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation
import UIPrimitives
import CardGuardianUI

public final class ProductProfileNavigationReducer {
    
    private let alertLifespan: DispatchTimeInterval

    public init(
        alertLifespan: DispatchTimeInterval = .seconds(1)
    ) {
        self.alertLifespan = alertLifespan
    }
}

public extension ProductProfileNavigationReducer {
    
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
        case let .open(panel):
            switch panel {
            case let .cardGuardianRoute(route):
                state.modal = .cardGuardian( .init(route.viewModel, route.cancellable))
            }
        case let .cardGuardianInput(cardGuardianInput):
            (state, effect) = reduce(state, cardGuardianInput)
        case let .productProfile(event):
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
        
        state.alert = nil
        
        switch cardGuardianInput {
        
        case .appear:
            break
        case let .buttonTapped(tap):
            switch tap {
                
            case let .toggleLock(card):
                state.modal = nil
                effect = .delayAlert(AlertModelOf.alertBlockCard(card), alertLifespan)
            case let .changePin(card):
                state.modal = nil
                effect = .productProfile(.changePin(card))
            case let .toggleVisibilityOnMain(product):
                state.modal = nil
                effect = .productProfile(.toggleVisibilityOnMain(product))
            }
        }
        
        return (state, effect)
    }
}

private extension ProductProfileNavigationReducer {
    
    func reduce(
        _ state: State,
        _ event: ProductProfileEvent
    ) -> (State, Effect?) {
        
        var effect: Effect?
        var state = state
        
        state.alert = nil

        switch event {
            
        case let .guardCard(card):
            effect = .productProfile(.guardCard(card))
        case let .toggleVisibilityOnMain(product):
            effect = .productProfile(.toggleVisibilityOnMain(product))
        case let .changePin(card):
            effect = .productProfile(.changePin(card))
        case .showContacts:
            effect = .productProfile(.showContacts)
        }
        return (state, effect)
    }
}
