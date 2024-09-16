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
                    productId: state.filter?.productId,
                    calendar: state.filter?.calendar ?? .init(
                        date: Date(),
                        range: .init(),
                        monthsData: [],
                        periods: []
                    ),
                    filter: .init(
                        title: "Фильтры",
                        selectDates: nil,
                        selectedServices: [],
                        periods: FilterHistoryState.Period.allCases,
                        transactionType: FilterHistoryState.TransactionType.allCases,
                        services: services,
                        historyService: { _,_ in
                                
                            print("### Open Sheet action")
                        }
                    ), dateFilter: { _,_ in
                        
                    }
                )
            case let .selectedDates(lowerDate: lowerDate, upperDate: upperDate):
                state.filter = .init(
                    productId: state.filter?.productId,
                    calendar: .init(
                        date: Date(),
                        range: .init(startDate: lowerDate, endDate: upperDate),
                        monthsData: [],
                        periods: []
                    ),
                    filter: .init(
                        title: "Фильтры",
                        selectDates: (lowerDate, upperDate),
                        selectedServices: [],
                        periods: FilterHistoryState.Period.allCases,
                        transactionType: FilterHistoryState.TransactionType.allCases,
                        services: state.history?.categories ?? [],
                        historyService: { _,_ in
                            
                            print("### selectedDates action")
                        }
                    ), dateFilter: { _,_ in
                        
                    }
                )
                
            case let .selectedCategory(category):
//                if state.filter?.selectedServices.contains(category) ?? false {
//                    state.filter?.selectedServices.remove(category)
//                } else {
                state.filter?.filter.selectedServices = category
//                }
                
            case let .selectedPeriod(period):
                if state.filter?.filter.selectedPeriod == period {
                    state.filter?.filter.selectedPeriod = .month
                } else {
                    state.filter?.filter.selectedPeriod = period
                }

            case let .selectedTransaction(transaction):
                if state.filter?.filter.selectedTransaction == transaction {
                    state.filter?.filter.selectedTransaction = nil
                } else {
                    state.filter?.filter.selectedTransaction = transaction
                }
                
            case .clearOptions:
                state.filter?.filter.selectedTransaction = nil
                state.filter?.filter.selectedPeriod = .month
                state.filter?.filter.selectedServices.removeAll()
                state.filter?.calendar.range = .init()
                
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

enum HistoryEvent {
    
    case button(ButtonEvent)
    case filter([ProductProfileViewModel.HistoryState.Filter]?)
    case calendar(Date?)
    case clearOptions
    case dismiss
    
    enum ButtonEvent {
        
        case calendar((Date?, Date?) -> Void)
        case filter(Date?, Date?)
    }
}
