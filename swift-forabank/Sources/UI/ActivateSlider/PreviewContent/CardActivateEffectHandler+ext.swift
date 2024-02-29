//
//  CardActivateEffectHandler+ext.swift
//
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import RxViewModel

public extension CardActivateEffectHandler {
    
    static func handleEffectActivateSuccess() -> RxViewModel<CardActivateState, CardActivateEvent, CardActivateEffect>.HandleEffect {
        
        CardActivateEffectHandler(handleCardEffect: CardEffectHandler.activateSuccess.handleEffect(_:_:)).handleEffect(_:_:)
    }
    
    static func handleEffectActivateFailure() -> RxViewModel<CardActivateState, CardActivateEvent, CardActivateEffect>.HandleEffect {
        
        CardActivateEffectHandler(handleCardEffect: CardEffectHandler.activateFailure.handleEffect(_:_:)).handleEffect(_:_:)
    }
}
