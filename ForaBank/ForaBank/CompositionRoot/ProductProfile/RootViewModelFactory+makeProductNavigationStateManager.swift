//
//  RootViewModelFactory+makeProductNavigationStateManager.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import Foundation

extension RootViewModelFactory {
    
    static func makeProductNavigationStateManager(
        alertsReduce: AlertReducer,
        bottomSheetReduce: BottomSheetReducer,
        handleEffect: ProductNavigationStateEffectHandler
    ) -> ProductNavigationStateManager {
        
        .init(
            alertReduce: alertsReduce.reduce(_:_:),
            bottomSheetReduce: bottomSheetReduce.reduce(_:_:),
            handleEffect: handleEffect.handleEffect(_:_:)
        )
    }
}

