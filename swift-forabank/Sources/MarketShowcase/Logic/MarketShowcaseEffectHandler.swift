//
//  MarketShowcaseEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public final class MarketShowcaseEffectHandler {
    
    public init(){}
}

public extension MarketShowcaseEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
          
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                dispatch(.loaded)
            }
        }
    }
}

public extension MarketShowcaseEffectHandler {
    
    typealias Event = MarketShowcaseEvent
    typealias Effect = MarketShowcaseEffect
    typealias Dispatch = (Event) -> Void
}
