//
//  ProductDetailsSheetEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import Foundation

public final class ProductDetailsSheetEffectHandler {
    
    public init(){}
}

public extension ProductDetailsSheetEffectHandler {
        
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension ProductDetailsSheetEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = ProductDetailsSheetEvent
    typealias Effect = ProductDetailsSheetEffect
}
