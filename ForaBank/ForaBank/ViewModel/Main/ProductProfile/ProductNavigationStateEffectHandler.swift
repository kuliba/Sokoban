//
//  ProductNavigationStateEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.04.2024.
//

import SwiftUI

final class ProductNavigationStateEffectHandler {
    
    init(){}
}

extension ProductNavigationStateEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert, dispatchTimeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                
                dispatch(.showAlert(alert))
            }
            
        case let .delayBottomSheet(bottomSheet, dispatchTimeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                
                dispatch(.showBottomSheet(bottomSheet))
            }
        }
    }
}

extension ProductNavigationStateEffectHandler {
    
    typealias Event = ProductNavigationEvent
    typealias Effect = ProductNavigationStateEffect
    typealias Dispatch = (Event) -> Void
}

enum ProductNavigationEvent {
    
    case showAlert(Alert.ViewModel)
    case showBottomSheet(ProductProfileViewModel.BottomSheet)
}
