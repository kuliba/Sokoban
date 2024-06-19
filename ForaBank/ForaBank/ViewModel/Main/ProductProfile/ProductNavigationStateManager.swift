//
//  ProductNavigationStateManager.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI

final class ProductProfileFlowReducer {

    typealias State = ProductProfileFlowState
    typealias Event = ProductProfileFlowEvent
    typealias Effect = ProductNavigationStateEffect

    typealias AlertReduce = (AlertState, AlertEvent) -> (AlertState, Effect?)
    typealias AlertState = Alert.ViewModel?

    typealias BottomSheetReduce = (BottomSheetState, BottomSheetEvent) -> (BottomSheetState, Effect?)
    typealias BottomSheetState = ProductProfileViewModel.BottomSheet?
    
    typealias HistoryReduce = (HistoryState?, HistoryEvent) -> (HistoryState?, Effect?)
    
    private let alertReduce: AlertReduce
    private let bottomSheetReduce: BottomSheetReduce
    private let historyReduce: HistoryReduce
    
    init(
        alertReduce: @escaping AlertReduce,
        bottomSheetReduce: @escaping BottomSheetReduce,
        historyReduce: @escaping HistoryReduce
    ) {
        self.alertReduce = alertReduce
        self.bottomSheetReduce = bottomSheetReduce
        self.historyReduce = historyReduce
    }
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
     
        var state = state
        var effect: Effect?
        
        switch event {
        case let .alert(alertEvent):
            let alert: AlertState
            (alert, effect) = alertReduce(state.alert, alertEvent)
            state.alert = alert
            
        case let .bottomSheet(bottomEvent):
            let bottomSheet: BottomSheetState
            (bottomSheet, effect) = bottomSheetReduce(state.bottomSheet, bottomEvent)
            state.bottomSheet = bottomSheet
            
        case let .history(historyEvent):
            let history: HistoryState?
            (history, effect) = historyReduce(state.history, historyEvent)
            state.history = history
        }
        
        return (state, effect)
    }
}

struct ProductNavigationStateManager {
    //TODO: rename ProductProfileFlowManager
    
    let reduce: Reduce
    let handleEffect: HandleEffect
    
    internal init(
        reduce: @escaping ProductNavigationStateManager.Reduce,
        handleEffect: @escaping ProductNavigationStateManager.HandleEffect
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
    }
}

extension ProductNavigationStateManager {
    
    typealias Reduce = (ProductProfileFlowState, ProductProfileFlowEvent) -> (ProductProfileFlowState, Effect?)
    
    typealias Effect = ProductNavigationStateEffect
    typealias Event = ProductNavigationEvent

    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

enum AlertEvent {
    
    case closeAlert
    case showAlert(Alert.ViewModel)
    case delayAlert(Kind)
    case delayAlertViewModel(Alert.ViewModel)
    
    enum Kind {
        case showAdditionalOtherAlert
        case showBlockAlert
        case showServiceOnlyMainCard
        case showServiceOnlyOwnerCard
        case showTransferAdditionalOther
    }
}

enum BottomSheetEvent {
    
    case showBottomSheet(ProductProfileViewModel.BottomSheet)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet)
}

enum ProductNavigationStateEffect { //TODO: rename ProductProfileFlowEffect
    
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet, DispatchTimeInterval)
}

extension ProductNavigationStateManager {
    
    static let preview: Self = .init(
        reduce: { state,_ in (state, nil) },
        handleEffect: ProductNavigationStateEffectHandler().handleEffect
    )
}

struct ProductProfileFlowState {
    
    var alert: Alert.ViewModel?
    var bottomSheet: ProductProfileViewModel.BottomSheet?
    var history: HistoryState? //TODO: replace to type
}

enum ProductProfileFlowEvent {
    case alert(AlertEvent)
    case bottomSheet(BottomSheetEvent)
    case history(HistoryEvent)
}

enum HistoryEvent: Equatable {
    case button(ButtonEvent)
    //case payload
    
    enum ButtonEvent: Equatable {
        case calendar
        case filter
    }
}
