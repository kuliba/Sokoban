//
//  LandingEffectHandler.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 03.03.2025.
//

import Foundation
import OrderCard

final class LandingEffectHandler<Landing> {
 
    typealias Load = (@escaping (Result<Landing, LoadFailure>) -> Void) -> Void
    
    private let load: Load
    
    init(load: @escaping Load) {
        self.load = load
    }
    
    func handleEffect(
        effect: Effect,
        dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case .load:
            load { dispatch(.loadResult($0)) }
        }
    }
    
    typealias Event = OrderCardLandingDomain.LandingEvent<Landing>
    typealias Effect = OrderCardLandingDomain.LandingEffect
}
