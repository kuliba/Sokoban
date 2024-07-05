//
//  ControlPanelReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import SwiftUI

final class ControlPanelReducer {
    
    private let controlPanelLifespan: DispatchTimeInterval
    private let makeAlert: MakeAlert
    private let makeActions: MakeActions

    init(
        controlPanelLifespan: DispatchTimeInterval = .milliseconds(400),
        makeAlert: @escaping MakeAlert,
        makeActions: MakeActions
    ) {
        self.controlPanelLifespan = controlPanelLifespan
        self.makeAlert = makeAlert
        self.makeActions = makeActions
    }
}

extension ControlPanelReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .controlButtonEvent(buttonEvent):
            (state, effect) = reduce(state, buttonEvent)
            
        case let .updateState(buttons):
            if state.status == .inflight(.updateProducts) {
                state.spinner = nil
            }
            if buttons != state.buttons {
                state.buttons = buttons
            }
            
        case .updateProducts:
            state.status = .inflight(.updateProducts)
            makeActions.updateProducts()
        }
        return (state, effect)
    }
}

extension ControlPanelReducer {
    
    func reduce(
        _ state: State,
        _ event: ControlButtonEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
         
        case let .delayAlert(card):
            
            guard let cardNumber = card.number, let statusCard = card.statusCard else {
                return (state, effect)
            }

            effect = .delayAlert(alertBlockedCard(with: card.id, card.isBlocked, cardNumber, statusCard), controlPanelLifespan)

        case let .showAlert(alertViewModel):
            state.alert = alertViewModel
            
        case let .blockCard(card):
            state.status = .inflight(.block)
            state.spinner = .init()
            effect = .blockCard(card)

        case let .unblockCard(card):
            state.status = .inflight(.unblock)
            state.spinner = .init()
            effect = .unblockCard(card)

        case let .changePin(productId):
            print("changePin")
            
        case let .visibility(card):
            state.status = .inflight(.visibility)
            state.spinner = .init()
            effect = .visibility(card)
        }
        return (state, effect)
    }
    
    // TODO: move to other place
    
    func alertBlockedCard(
        with cardID: ProductCardData.ID,
        _ isBlocked: Bool,
        _ cardNumber: String,
        _ statusCard: ProductCardData.StatusCard
        
    ) -> Alert.ViewModel {
        
        let secondaryButton: Alert.ViewModel.ButtonViewModel = {
            switch statusCard {
            case .blockedUnlockNotAvailable:
                return .init(
                    type: .default,
                    title: "Контакты",
                    action: makeActions.contactsAction)

            default:
                return .init(
                    type: .default,
                    title: "Oк",
                    action: {
                        if isBlocked {
                            self.makeActions.unblockAction()
                        } else {
                            self.makeActions.blockAction()
                        }
                    })
            }
        }()
        
        let alertViewModel = makeAlert(
            .init(
                statusCard: statusCard,
                primaryButton: .init(
                    type: .default,
                    title: "Отмена",
                    action: {}),
                secondaryButton: secondaryButton)
        )
                
        return alertViewModel
    }
}

extension ControlPanelReducer {
    
    struct MakeActions {
        let contactsAction: MakeAction
        let blockAction: MakeAction
        let unblockAction: MakeAction
        let updateProducts: MakeAction
    }
}

extension ControlPanelReducer {
    
    typealias Event = ControlPanelEvent
    typealias State = ControlPanelState
    typealias Effect = ControlPanelEffect
    typealias MakeAlert = (ProductProfileViewModelFactory.AlertParameters) -> Alert.ViewModel
    typealias MakeAction = () -> Void
}
