//
//  RootViewModelFactory+makeProductsLandingContent.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 12.03.2025.
//

import OrderCardLandingComponent

extension RootViewModelFactory {
    
    @inlinable
    func makeProductsLandingContent<Landing>(
        load: @escaping (@escaping (Result<Landing, OrderCardLandingComponent.LoadFailure>) -> Void) -> Void
    ) -> CardLandingContentDomain<Landing>.Content {
        
        let reducer = CardLandingContentDomain<Landing>.Reducer()
        let effectHandler = CardLandingContentDomain<Landing>.EffectHandler(
            load: load
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:event:),
            handleEffect: effectHandler.handleEffect(effect:dispatch:),
            scheduler: schedulers.main
        )
    }
}
