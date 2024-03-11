//
//  ProductDetailsEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public final class ProductDetailsEffectHandler {
    
    public init(){}
}

public extension ProductDetailsEffectHandler {
        
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension ProductDetailsEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = ProductDetailsEvent
    typealias Effect = ProductDetailsEffect
}
