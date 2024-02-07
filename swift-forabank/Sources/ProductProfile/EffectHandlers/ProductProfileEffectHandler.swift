//
//  ProductProfileEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import Foundation

public final class ProductProfileEffectHandler {
    
    public init() {}
}

public extension ProductProfileEffectHandler {
    
#warning("add tests")
    func handleEffect(
        _ effect: ProductProfileNavigation.Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
        switch effect {
        case let .delayAlert(alert):
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                dispatch(.showAlert(alert))
            }
        }
    }
}

public extension ProductProfileEffectHandler {
    
    typealias Event = ProductProfileNavigation.Event
    typealias Effect = ProductProfileNavigation.Effect
    
    typealias Dispatch = (Event) -> Void
}
