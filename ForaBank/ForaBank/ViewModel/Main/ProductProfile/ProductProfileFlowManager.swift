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
    
    typealias HistoryReduce = (ProductProfileViewModel.HistoryState?, HistoryEvent) -> (ProductProfileViewModel.HistoryState?, HistoryEffect?)
    
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
        
        case let .button(event):
            switch event {
            case .calendar:
                state.history = .init(
                    buttonAction: .calendar,
                    showSheet: .calendar,
                    categories: [],
                    applyAction: { _,_ in}
                )
                
            case .filter:
                let (history, historyEffect) = historyReduce(
                    state.history,
                    .button(.filter(
                        state.filter.productId,
                        nil
                    )))
                state.history = history
                effect = historyEffect.map(Effect.history)
            }
            
        case let .bottomSheet(bottomEvent):
            let bottomSheet: BottomSheetState
            (bottomSheet, effect) = bottomSheetReduce(state.bottomSheet, bottomEvent)
            state.bottomSheet = bottomSheet
            
        case let .history(historyEvent):
            let (history, historyEffect) = historyReduce(state.history, historyEvent)
            state.history = history
            effect = historyEffect.map(Effect.history)
        
        case .updateFilter(nil):
            fatalError()
            break
            
        case let .updateFilter(.some(filterState)):
            state.filter = filterState
            state.history?.showSheet = nil
            
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
        case showServiceOnlyIndividualCard
    }
}

enum BottomSheetEvent {
    
    case showBottomSheet(ProductProfileViewModel.BottomSheet)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet)
}

enum ProductProfileFlowEffect {
    
    case delayAlert(Alert.ViewModel, DispatchTimeInterval)
    case delayBottomSheet(ProductProfileViewModel.BottomSheet, DispatchTimeInterval)
    case history(HistoryEffect)
}

extension ProductProfileFlowManager {
    
    static let preview: Self = .init(
        reduce: ProductProfileFlowReducer(
            alertReduce: AlertReducer(alertLifespan: .microseconds(0), productAlertsViewModel: .default).reduce,
            bottomSheetReduce: BottomSheetReducer(bottomSheetLifespan: .microseconds(0)).reduce,
            historyReduce: HistoryReducer().reduce
        ).reduce,
        handleEffect: ProductNavigationStateEffectHandler(
            handleHistoryEffect: { _,_ in }
        ).handleEffect,
        handleModelEffect: {_,_ in }
    )
}

struct ProductProfileFlowState {
    
    var alert: Alert.ViewModel?
    var bottomSheet: ProductProfileViewModel.BottomSheet?
    var history: ProductProfileViewModel.HistoryState?
    var filter: FilterState
    var payment: PaymentsViewModel
}

enum ProductProfileFlowEvent {
    
    case alert(AlertEvent)
    case bottomSheet(BottomSheetEvent)
    case history(HistoryEvent)
    case updateFilter(FilterState?)
    case payment(PaymentsViewModel)
    case button(ButtonEvent)
    
    enum ButtonEvent {
        
        case calendar
        case filter
    }
}

enum HistoryEvent {
    
    case button(ButtonEvent)
    case filter(FilterEvent)
    case calendar(Date?)
    case clearOptions
    case receive(FilterViewModel)
    case dismiss
    
    enum FilterEvent {
        case calendar(CalendarEvent)
        case period(CalendarState)
        case dismissCalendar
    }
    
    enum ButtonEvent {
        
        case calendar((Date?, Date?) -> Void)
        case filter(ProductData.ID, Range<Date>?)
    }
}

