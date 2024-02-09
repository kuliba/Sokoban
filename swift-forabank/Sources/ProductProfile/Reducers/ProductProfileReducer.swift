//
//  ProductProfileReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2024.
//

import Foundation
import UIPrimitives
import CardGuardianModule

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
        case let .closeAlert(action):
            state.alert = nil

            switch action {
            case .close:
                break
            case .changePin:
                effect = .action(.changePin)
            case .lockCard:
                effect = .action(.lockCard)
            case .unlockCard:
                effect = .action(.unlockCard)
            case .showСontacts:
                effect = .action(.showСontacts)
            }
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
            (state, effect) = reduce(state, cardGuardianInput)            
        case let .action(action):
            switch action {
                
            case .showOnMain:
                state.modal = nil
                print ("send request hideOnMain")

            case .hideOnMain:
                state.modal = nil
                print ("send request showOnMain")
                
            case .changePin:
                print ("change pin")
            
            case .lockCard:
                print ("send request lock card")

            case .unlockCard:
                print ("send request unlock card")

            case .showСontacts:
                print ("showСontacts")
            }
        case let .onMain(status):
            effect = .action(.onMain(status))
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

private extension ProductProfileReducer {
    
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
                
            case let .toggleLock(status):
                state.modal = nil
                effect = .delayAlert(Alerts.alertBlockCard(status))
            case .changePin:
                state.modal = nil
                effect = .delayAlert(Alerts.alertChangePin())

            case let .onMain(status):
                state.modal = nil
                effect = .action(.onMain(status))
            }
        }
        
        return (state, effect)
    }
}
