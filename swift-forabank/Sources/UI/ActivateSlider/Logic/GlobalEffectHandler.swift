//
//  GlobalEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation

public final class GlobalEffectHandler {
    
    private let handleCardEffect: HandleCardEffect
    
    public init(
        handleCardEffect: @escaping HandleCardEffect
    ) {
        self.handleCardEffect = handleCardEffect
    }
}

public extension GlobalEffectHandler {
    
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

public extension GlobalEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = GlobalEvent
    typealias Effect = GlobalEffect
    
    typealias CardDispatch = (CardEvent) -> Void
    typealias HandleCardEffect = (CardEffect, @escaping CardDispatch) -> Void
}
