//
//  MarketShowcaseEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public final class MarketShowcaseEffectHandler {
    
    private let makeInformer: () -> Void
    private let makeAlert: (String) -> Void

    public init(
        makeInformer: @escaping () -> Void,
        makeAlert: @escaping (String) -> Void
    ) {
        self.makeInformer = makeInformer
        self.makeAlert = makeAlert
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
                DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) { [weak self] in
                    self?.makeAlert("Попробуйте позже")
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
