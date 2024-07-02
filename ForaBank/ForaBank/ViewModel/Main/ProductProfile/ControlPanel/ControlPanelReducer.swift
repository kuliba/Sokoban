//
//  ControlPanelReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation

final class ControlPanelReducer {
    
    private let controlPanelLifespan: DispatchTimeInterval
    private let controlPanelFlowManager: ControlPanelFlowManager
    private let productProfileServices: ProductProfileServices

    init(
        controlPanelLifespan: DispatchTimeInterval = .milliseconds(400),
        controlPanelFlowManager: ControlPanelFlowManager,
        productProfileServices: ProductProfileServices
    ) {
        self.controlPanelLifespan = controlPanelLifespan
        self.controlPanelFlowManager = controlPanelFlowManager
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
}

extension ControlPanelReducer {
    
    typealias Event = ControlPanelEvent
    typealias State = ControlPanelState
    typealias Effect = ControlPanelEffect
}
