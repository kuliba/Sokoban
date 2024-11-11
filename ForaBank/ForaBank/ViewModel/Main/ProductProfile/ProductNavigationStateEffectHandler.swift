//
//  ProductNavigationStateEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 12.04.2024.
//

import SwiftUI
import CalendarUI

final class ProductNavigationStateEffectHandler {
    
    typealias HistoryDispatch = (HistoryEvent) -> Void
    typealias HandleHistoryEffect = (HistoryEffect, @escaping HistoryDispatch) -> Void
    
    private let handleHistoryEffect: HandleHistoryEffect
    
    init(handleHistoryEffect: @escaping HandleHistoryEffect) {
        self.handleHistoryEffect = handleHistoryEffect
    }
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
        case let .history(historyEffect):
            handleHistoryEffect(historyEffect) { dispatch(.history($0)) }
        }
    }
}

extension ProductNavigationStateEffectHandler {
    
    typealias Event = ProductNavigationEvent
    typealias Effect = ProductProfileFlowEffect
    typealias Dispatch = (Event) -> Void
}

enum ProductNavigationEvent {
    
    case showAlert(Alert.ViewModel)
    case showBottomSheet(ProductProfileViewModel.BottomSheet)
    case history(HistoryEvent)
}
