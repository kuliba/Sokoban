//
//  DetailsEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public final class DetailsEffectHandler {
    
    public init(){}
}

public extension DetailsEffectHandler {
        
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension DetailsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = DetailsEvent
    typealias Effect = DetailsEffect
}
