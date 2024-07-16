//
//  ControlPanelReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import SwiftUI
import LandingUIComponent

final class ControlPanelReducer {
    
    private let controlPanelLifespan: DispatchTimeInterval
    private let makeAlert: MakeAlert
    private let makeActions: MakeActions
    private let makeViewModels: MakeViewModels

    init(
        controlPanelLifespan: DispatchTimeInterval = .milliseconds(400),
        makeAlert: @escaping MakeAlert,
        makeActions: MakeActions,
        makeViewModels: MakeViewModels
    ) {
        self.controlPanelLifespan = controlPanelLifespan
        self.makeAlert = makeAlert
        self.makeActions = makeActions
        self.makeViewModels = makeViewModels
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
            
        case let .bannerEvent(bannerEvent):
            (state, effect) = reduce(state, bannerEvent)

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
            
        case let .updateTitle(newTitle):
            state.navigationBarViewModel.title = newTitle
            
        case let .loadSVCardLanding(card):
            effect = .loadSVCardLanding(card)
            
        case let .loadedSVCardLanding(viewModel):
            if let viewModel {
                state.landingWrapperViewModel = viewModel
            } else {
                state.landingWrapperViewModel = nil
            }
            
        case let .loadedSVCardLimits(limits):
            print("limits \(String(describing: limits))")
            
        case .dismissDestination:
            state.destination = nil
        }
        return (state, effect)
    }
}

extension ControlPanelReducer {
    
    func reduce(
        _ state: State,
        _ event: BannerActionEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .contactTransfer(viewModel):
            state.destination = .contactTransfer(viewModel)
         
        case let .migTransfer(viewModel):
            state.destination = .migTransfer(viewModel)

        case let .stickerEvent(stickerEvent):
            switch stickerEvent {
            case let .openCard(viewModel):
                state.destination = .landing(viewModel)
                
            case let .orderSticker(view):
                state.destination = .orderSticker(view)
            }
            
        case let .openDeposit(viewModel):
            state.destination = .openDeposit(viewModel)
            
        case let .openDepositsList(viewModel):
            state.destination = .openDepositsList(viewModel)
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

        case let .changePin(card):
            makeActions.changePin(card)
            
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
        
        let blockAction: MakeAction
        let changePin: (ProductCardData) -> Void
        let contactsAction: MakeAction
        let unblockAction: MakeAction
        let updateProducts: MakeAction
    }
}

extension ControlPanelReducer {
    
    struct MakeViewModels {
        
        let stickerLanding: LandingWrapperViewModel
    }
}

extension ControlPanelReducer {
    
    typealias Event = ControlPanelEvent
    typealias State = ControlPanelState
    typealias Effect = ControlPanelEffect
    typealias MakeAlert = (ProductProfileViewModelFactory.AlertParameters) -> Alert.ViewModel
    typealias MakeAction = () -> Void
}
