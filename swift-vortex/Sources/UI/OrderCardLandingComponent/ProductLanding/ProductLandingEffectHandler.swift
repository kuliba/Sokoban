//
//  ProductLandingEffectHandler.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation

public final class ProductLandingEffectHandler<Landing> {
    
    private let load: Load
    
    public init(load: @escaping Load) {
        self.load = load
    }
}

public extension ProductLandingEffectHandler {
    
    func handleEffect(
        effect: Effect,
        dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case .load:
            load { dispatch(.loadResult($0)) }
        }
    }
    
    typealias Load = (@escaping (Result<Landing, LoadFailure>) -> Void) -> Void
    typealias Event = LandingEvent<Landing>
    typealias Effect = LandingEffect
}
