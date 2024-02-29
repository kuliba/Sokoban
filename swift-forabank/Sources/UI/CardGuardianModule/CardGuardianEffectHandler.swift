//
//  CardGuardianEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

public final class CardGuardianEffectHandler {
    
    public init(){}
}

public extension CardGuardianEffectHandler {
        
    func handleEffect(
        _ effect: CardGuardianEffect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension CardGuardianEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CardGuardianEvent
    typealias Effect = CardGuardianEffect
}
