//
//  ProductNavigationStateManager.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI

struct ProductNavigationStateManager {
    
    let alertReduce: AlertReduce
    let bottomSheetReduce: BottomSheetReduce
    let handleEffect: HandleEffect
}

extension ProductNavigationStateManager {
    
    typealias Effect = ProductNavigationStateEffect
    typealias Event = ProductNavigationEvent

    typealias AlertReduce = (AlertState, AlertEvent) -> (AlertState, Effect?)
    typealias AlertState = Alert.ViewModel?

    typealias BottomSheetReduce = (BottomSheetState, BottomSheetEvent) -> (BottomSheetState, Effect?)
    typealias BottomSheetState = ProductProfileViewModel.BottomSheet?

    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

enum AlertEvent {
    
    case closeAlert
    case showAlert(Alert.ViewModel)
    case delayAlert(Kind)
    
    enum Kind {
        case showAdditionalOtherAlert
        case showBlockAlert
        case showServiceOnlyMainCard
        case showServiceOnlyOwnerCard
    }
}

enum BottomSheetEvent {
    
    case showBottomSheet(ProductProfileViewModel.BottomSheet)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet)
}

enum ProductNavigationStateEffect {
    
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet, DispatchTimeInterval)
}

extension ProductNavigationStateManager {
    
    static let preview: Self = .init(
        alertReduce: AlertReducer(productAlertsViewModel: .default).reduce,
        bottomSheetReduce: BottomSheetReducer().reduce,
        handleEffect: ProductNavigationStateEffectHandler().handleEffect
    )
}
