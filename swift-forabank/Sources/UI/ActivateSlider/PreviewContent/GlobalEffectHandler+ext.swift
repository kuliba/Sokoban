//
//  GlobalEffectHandler+ext.swift
//
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import RxViewModel

public extension GlobalEffectHandler {
    
    static func handleEffectActivateSuccess() -> RxViewModel<GlobalState, GlobalEvent, GlobalEffect>.HandleEffect {
        
        GlobalEffectHandler(handleCardEffect: CardEffectHandler.activateSuccess.handleEffect(_:_:)).handleEffect(_:_:)
    }
    
    static func handleEffectActivateFailure() -> RxViewModel<GlobalState, GlobalEvent, GlobalEffect>.HandleEffect {
        
        GlobalEffectHandler(handleCardEffect: CardEffectHandler.activateFailure.handleEffect(_:_:)).handleEffect(_:_:)
    }
}
