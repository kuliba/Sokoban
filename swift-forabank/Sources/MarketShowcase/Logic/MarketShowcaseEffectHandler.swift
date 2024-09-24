//
//  MarketShowcaseEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

final class MarketShowcaseEffectHandler {
    
    init(){}
}

extension MarketShowcaseEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
          
            DispatchQueue.main.delay(for: .seconds(2)) {
                dispatch(.loaded)
            }
        }
    }
}

extension MarketShowcaseEffectHandler {
    
    typealias Event = MarketShowcaseEvent
    typealias Effect = MarketShowcaseEffect
    typealias Dispatch = (Event) -> Void
}
