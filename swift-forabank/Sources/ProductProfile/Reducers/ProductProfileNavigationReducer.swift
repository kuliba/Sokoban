//
//  ProductProfileNavigationReducer.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation
import UIPrimitives

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
        case let .create(panelKind):
            state.modal = nil
            switch panelKind {
            case .accountInfo:
                effect = .create(.accountInfo)
            case .cardGuardian:
                effect = .create(.cardGuardian)
            case .productDetails:
                effect = .create(.productDetails)
            case .topUpCard:
                effect = .create(.topUpCard)
            case .share:
                effect = .create(.share)
            }
        case .dismissModal:
            if let status = state.destination?.viewModel.state.status {
                if status == .itemTapped(.share) {
                    state.destination?.viewModel.event(.closeModal)
                }
            } else {
                state.modal = nil
            }
        case .dismissDestination:
            state.destination?.viewModel.event(.close)
        case let .showAlert(alert):
            state.alert = alert
        case let .open(panel):
            switch panel {
            case let .accountInfoPanelRoute(route):
                state.modal = .accountInfo( .init(route.viewModel, route.cancellable))
            case let .cardGuardianRoute(route):
                state.modal = .cardGuardian( .init(route.viewModel, route.cancellable))
            case let .productDetailsRoute(route):
                state.modal = nil
                state.destination = .init(route.viewModel, route.cancellable)
            case let .topUpCardRoute(route):
                state.modal = .topUpCard(.init(route.viewModel, route.cancellable))
            case let .productDetailsSheetRoute(route):
                state.modal = .share(.init(route.viewModel, route.cancellable))
            }
        case let .accountInfoPanelInput(accountInfoPanelInput):
            (state, effect) = reduce(state, accountInfoPanelInput)
        case let .cardGuardianInput(cardGuardianInput):
            (state, effect) = reduce(state, cardGuardianInput)
        case let .productDetailsInput(detailsInput):
            (state, effect) = reduce(state, detailsInput)
        case let .topUpCardInput(topUpCardInput):
            (state, effect) = reduce(state, topUpCardInput)

        case let .productProfile(event):
            (state, effect) = reduce(state, event)
        case let .productDetailsSheetInput(event):
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
        _ topUpCardInput: TopUpCardStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.alert = nil
        
        switch topUpCardInput {
        
        case .appear:
            break
        case let .buttonTapped(tap):
            switch tap {
                
            case let .accountAnotherBank(card):
                state.modal = nil
                effect = .productProfile(.accountAnotherBank(card))

            case let .accountOurBank(card):
                state.modal = nil
                effect = .productProfile(.accountOurBank(card))
            }
        }
        
        return (state, effect)
    }
}

private extension ProductProfileNavigationReducer {
    
    func reduce(
        _ state: State,
        _ topUpCardInput: AccountInfoPanelStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.alert = nil
        
        switch topUpCardInput {
        
        case .appear:
            break
        case let .buttonTapped(tap):
            switch tap {
                
            case let .accountDetails(card):
                state.modal = nil
                effect = .productProfile(.accountDetails(card))

            case let .accountStatement(card):
                state.modal = nil
                effect = .productProfile(.accountStatement(card))
            }
        }
        
        return (state, effect)
    }
}

private extension ProductProfileNavigationReducer {
    
    func reduce(
        _ state: State,
        _ input: ProductDetailsSheetStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        
        state.alert = nil
        
        switch input {
        case .appear:
            break
            
        case let .buttonTapped(tap):
            switch tap {
            case .sendAll:
                state.modal = nil
                state.destination?.viewModel.event(.sendAll)

            case .sendSelect:
                state.modal = nil
                state.destination?.viewModel.event(.sendSelect)
            }
        }
        return (state, .none)
    }
}

private extension ProductProfileNavigationReducer {
    
    func reduce(
        _ state: State,
        _ input: ProductDetailsStateProjection
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.alert = nil
        
        switch input {
        
        case .appear:
            break
        case let .itemTapped(tap):
            switch tap {
                
            case let .iconTap(documentId):
                switch documentId {
                case .info:
                    effect = .delayAlert(AlertModelOf.alertCVV(), alertLifespan)
                default:
                    effect = .productProfile(.productDetailsIconTap(documentId))
                }

            case let .longPress(valueForCopy, textForInformer):
                effect = .productProfile(.productDetailsItemlongPress(valueForCopy, textForInformer))
                
            case .share:
                effect = .create(.share)
            case .selectAccountValue, .selectCardValue:
                break
            }
        case .close:
            state.destination = nil
        case .sendAll:
            break
        case .sendSelect:
            break
        case .closeModal:
            if state.destination?.viewModel.state.status == .itemTapped(.share) {
                state.modal = nil
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
