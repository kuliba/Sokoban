//
//  MarketShowcaseEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public final class MarketShowcaseEffectHandler {
    
    private let makeInformer: () -> Void

    public init(
        makeInformer: @escaping () -> Void
    ) {
        self.makeInformer = makeInformer
    }
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
        case let .show(info):
            
            switch info {
            case .informer:
                makeInformer()
            case let .alert(dispatchTimeInterval):
                DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) { 
                    dispatch(.showAlert)
                }
            }
        }
    }
}

public extension MarketShowcaseEffectHandler {
    
    typealias Event = MarketShowcaseEvent
    typealias Effect = MarketShowcaseEffect
    typealias Dispatch = (Event) -> Void
}
