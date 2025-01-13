//
//  CardEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import Foundation

public final class CardEffectHandler {
    
    private let activate: Activate
    
    public init(
        activate: @escaping Activate
    ) {
        self.activate = activate
    }
}

public extension CardEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .activate(cardID):
            activate(cardID, dispatch)
            
        case let .dismiss(timeInterval):
            asyncAfter(timeInterval) { dispatch(.dismissActivate) }
            
        case let .confirmation(payload, timeInterval):
            asyncAfter(timeInterval) { dispatch(.activateCard(payload)) }
        }
    }
    
    private func asyncAfter(
        _ timeInterval: DispatchTimeInterval,
        _ action: @escaping () -> Void
    ) {
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeInterval,
            execute: action
        )
    }
}

public extension CardEffectHandler {
    
    typealias ActivatePayload = Effect.ActivatePayload
    typealias ActivateResult = Event.ActivateCardResponse
    typealias ActivateCompletion = (ActivateResult) -> Void
    typealias Activate = (ActivatePayload, @escaping ActivateCompletion) -> Void // request Unlock
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CardEvent
    typealias Effect = CardEffect
}

private extension CardEffectHandler {
    
    func activate(
        _ payload: ActivatePayload,
        _ dispatch: @escaping Dispatch
    ) {
        activate(payload) { dispatch(.activateCardResponse($0)) }
    }
}
