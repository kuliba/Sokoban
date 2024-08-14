//
//  ProductNavigationStateManager.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI
import CalendarUI

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
            
        case let .filter(filterEvent):
            
            switch filterEvent {
            case let .openSheet(services):
                state.filter = .init(
                    title: "Фильтры",
                    selectedServices: [],
                    periods: FilterState.Period.allCases,
                    transactionType: FilterState.TransactionType.allCases,
                    services: services
                )
                
            case let .selectedCategory(category):
                state.filter?.selectedServices.insert(category)

            case let .selectedPeriod(period):
                state.filter?.selectedPeriod = period

            case let .selectedTransaction(transaction):
                state.filter?.selectedTransaction = transaction
                
            case .clearOptions:
                state.filter?.selectedTransaction = nil
                state.filter?.selectedPeriod = .month
                state.filter?.selectedServices.removeAll()
                
            }
            
        case let .payment(paymentViewModel):
            state.payment = paymentViewModel
        }
        
        return (state, effect)
    }
}

struct ProductProfileFlowManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
    let handleModelEffect: HandleModelEffect
    
    internal init(
        reduce: @escaping ProductProfileFlowManager.Reduce,
        handleEffect: @escaping HandleEffect,
        handleModelEffect: @escaping HandleModelEffect
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
        self.handleModelEffect = handleModelEffect
    }
}

extension ProductProfileFlowManager {
    
    typealias Reduce = (ProductProfileFlowState, ProductProfileFlowEvent) -> (ProductProfileFlowState, Effect?)
    
    typealias Effect = ProductProfileFlowEffect
    typealias Event = ProductNavigationEvent

    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    typealias HandleModelEffect = ControlPanelEffectHandler.HandleModelEffect
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
        handleModelEffect: {_,_ in }
    )
}

struct ProductProfileFlowState {
    
    var alert: Alert.ViewModel?
    var bottomSheet: ProductProfileViewModel.BottomSheet?
    var history: ProductProfileViewModel.HistoryState?
    var filter: FilterState?
    var payment: PaymentsViewModel
}

enum ProductProfileFlowEvent {
    case alert(AlertEvent)
    case bottomSheet(BottomSheetEvent)
    case history(HistoryEvent)
    case filter(FilterEvent)
    case payment(PaymentsViewModel)
}

enum HistoryEvent: Equatable {
    
    case button(ButtonEvent)
    case filter([ProductProfileViewModel.HistoryState.Filter]?)
    case calendar(Date?)
    case clearOptions
    case dismiss
    
    enum ButtonEvent: Equatable {
        
        case calendar
        case filter
    }
}
