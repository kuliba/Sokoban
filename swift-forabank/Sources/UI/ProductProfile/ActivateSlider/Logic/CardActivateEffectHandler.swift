//
//  CardActivateEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation

public final class CardActivateEffectHandler {
    
    private let handleCardEffect: HandleCardEffect
    
    public init(
        handleCardEffect: @escaping HandleCardEffect
    ) {
        self.handleCardEffect = handleCardEffect
    }
}

public extension CardActivateEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case let .card(cardEffect):
            handleCardEffect(cardEffect) { dispatch(.card($0)) }
        }
    }
}

public extension CardActivateEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CardActivateEvent
    typealias Effect = CardActivateEffect
    
    typealias CardDispatch = (CardEvent) -> Void
    typealias HandleCardEffect = (CardEffect, @escaping CardDispatch) -> Void
}
