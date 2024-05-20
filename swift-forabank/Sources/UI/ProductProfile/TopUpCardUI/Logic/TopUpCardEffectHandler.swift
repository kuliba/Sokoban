//
//  TopUpCardEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 29.02.2024.
//

import Foundation

public final class TopUpCardEffectHandler {
    
    public init(){}
}

public extension TopUpCardEffectHandler {
        
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension TopUpCardEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TopUpCardEvent
    typealias Effect = TopUpCardEffect
}
