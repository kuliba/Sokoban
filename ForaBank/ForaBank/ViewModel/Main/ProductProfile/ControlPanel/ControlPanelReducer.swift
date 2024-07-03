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
    private let productProfileServices: ProductProfileServices
    private let makeAlert: MakeAlert
    private let makeContactsAction: MakeContactsAction

    init(
        controlPanelLifespan: DispatchTimeInterval = .milliseconds(400),
        makeAlert: @escaping MakeAlert,
        makeContactsAction: @escaping MakeContactsAction,
        productProfileServices: ProductProfileServices
    ) {
        self.controlPanelLifespan = controlPanelLifespan
        self.makeAlert = makeAlert
        self.makeContactsAction = makeContactsAction
        self.productProfileServices = productProfileServices
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
            if buttons != state.buttons {
                state.buttons = buttons
            }
        case let .alert(info):
            break
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
            
        case let .showAlert(card):
            
            state.alert = alertBlockedCard(with: card)
            
        case let .blockCard(card):
            productProfileServices.createBlockCardService.createBlockCard(.init(cardId: .init(card.cardId), cardNumber: .init(card.number ?? ""))) { result in
                switch result {
                case .failure:
                    break
                case .success:
                    break
                }
            }

        case let .unblockCard(card):
            productProfileServices.createUnblockCardService.createUnblockCard(.init(cardId: .init(card.cardId), cardNumber: .init(card.number ?? ""))) { result in
                switch result {
                case .failure:
                    break
                case .success:
                    break
                }
            }

        case let .changePin(productId):
            print("changePin")
            
        case let .visibility(productId):
            print("visibility")
            
        }
        return (state, effect)
    }
    
    func alertBlockedCard(
        with card: ProductCardData
    ) -> Alert.ViewModel? {
        
        guard let cardNumber = card.number, let statusCard = card.statusCard else {
            return nil
        }
        
        let secondaryButton: Alert.ViewModel.ButtonViewModel = {
            switch statusCard {
            case .blockedUnlockNotAvailable:
                return .init(
                    type: .default,
                    title: "Контакты",
                    action: makeContactsAction)

            default:
                return .init(
                    type: .default,
                    title: "Oк",
                    action: {
                        if card.isBlocked {
                            
                            self.productProfileServices.createUnblockCardService.createUnblockCard(.init(cardId: .init(card.id), cardNumber: .init(cardNumber))) { result in
                                
                            }
                        } else {
                            self.productProfileServices.createBlockCardService.createBlockCard(.init(cardId: .init(card.id), cardNumber: .init(cardNumber))) { result in
                            }
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
    
    typealias Event = ControlPanelEvent
    typealias State = ControlPanelState
    typealias Effect = ControlPanelEffect
    typealias MakeAlert = (ProductProfileViewModelFactory.AlertParameters) -> Alert.ViewModel
    typealias MakeContactsAction = () -> Void
}
