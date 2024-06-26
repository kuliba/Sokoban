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
    typealias Effect = ProductProfileFlowEffect

    typealias AlertReduce = (AlertState, AlertEvent) -> (AlertState, Effect?)
    typealias AlertState = Alert.ViewModel?

    typealias BottomSheetReduce = (BottomSheetState, BottomSheetEvent) -> (BottomSheetState, Effect?)
    typealias BottomSheetState = ProductProfileViewModel.BottomSheet?
    
    typealias HistoryReduce = (ProductProfileViewModel.HistoryState?, HistoryEvent) -> (ProductProfileViewModel.HistoryState?, Effect?)
    
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
            let history: ProductProfileViewModel.HistoryState?
            (history, effect) = historyReduce(state.history, historyEvent)
            state.history = history
        }
        
        return (state, effect)
    }
}

struct ProductProfileFlowManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
    let limitsFlag: LimitsFlag
    
    internal init(
        reduce: @escaping ProductProfileFlowManager.Reduce,
        handleEffect: @escaping ProductProfileFlowManager.HandleEffect,
        limitsFlag: LimitsFlag
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
        self.limitsFlag = limitsFlag
    }
}

extension ProductProfileFlowManager {
    
    typealias Reduce = (ProductProfileFlowState, ProductProfileFlowEvent) -> (ProductProfileFlowState, Effect?)
    
    typealias Effect = ProductProfileFlowEffect
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

enum ProductProfileFlowEffect {
    
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet, DispatchTimeInterval)
}

extension ProductProfileFlowManager {
    
    static let preview: Self = .init(
        reduce: ProductProfileFlowReducer(
            alertReduce: AlertReducer(alertLifespan: .microseconds(0), productAlertsViewModel: .default).reduce,
            bottomSheetReduce: BottomSheetReducer(bottomSheetLifespan: .microseconds(0)).reduce,
            historyReduce: HistoryReducer().reduce
        ).reduce,
        handleEffect: ProductNavigationStateEffectHandler().handleEffect,
        limitsFlag: .init(.inactive)
    )
}

struct ProductProfileFlowState {
    
    var alert: Alert.ViewModel?
    var bottomSheet: ProductProfileViewModel.BottomSheet?
    var history: ProductProfileViewModel.HistoryState?
}

enum ProductProfileFlowEvent {
    case alert(AlertEvent)
    case bottomSheet(BottomSheetEvent)
    case history(HistoryEvent)
}

enum HistoryEvent: Equatable {
    
    case button(ButtonEvent)
    
    enum ButtonEvent: Equatable {
        case calendar
        case filter
    }
}
