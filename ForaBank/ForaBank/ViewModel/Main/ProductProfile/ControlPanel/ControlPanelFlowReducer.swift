//
//  ControlPanelFlowReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.07.2024.
//

import Foundation
import SwiftUI
import UIPrimitives

final class ControlPanelFlowReducer {

    typealias State = ControlPanelFlowState
    typealias Event = ControlPanelFlowEvent
    typealias Effect = ControlPanelFlowEffect

    typealias AlertReduce = (AlertState, AlertEvent) -> (AlertState, Effect?)
    typealias AlertState = Alert.ViewModel?
    
    private let alertReduce: AlertReduce
    
    init(
        alertReduce: @escaping AlertReduce
    ) {
        self.alertReduce = alertReduce
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
        }
        return (state, effect)
    }
}

struct ControlPanelFlowManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
    
    internal init(
        reduce: @escaping ControlPanelFlowManager.Reduce,
        handleEffect: @escaping ControlPanelFlowManager.HandleEffect
    ) {
        self.reduce = reduce
        self.handleEffect = handleEffect
    }
}

extension ControlPanelFlowManager {
    
    typealias Reduce = (ControlPanelFlowState, ControlPanelFlowEvent) -> (ControlPanelFlowState, Effect?)
    
    typealias Effect = ControlPanelFlowEffect
    typealias Event = ControlPanelNavigationEvent

    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

enum ControlPanelFlowEffect {
    
    case delayAlert(AlertModelOf<AlertEvent>, DispatchTimeInterval)
    case delayAlertViewModel(Alert.ViewModel, DispatchTimeInterval)
}

extension ControlPanelFlowManager {
    
    static let preview: Self = .init(
        reduce: ControlPanelFlowReducer(
            alertReduce: ControlPanelAlertReducer(alertLifespan: .microseconds(0), productAlertsViewModel: .default).reduce
        ).reduce,
        handleEffect: ControlPanelNavigationStateEffectHandler().handleEffect
    )
}

struct ControlPanelFlowState {
    
    var alert: Alert.ViewModel?
}

enum ControlPanelFlowEvent {
    case alert(AlertEvent)
}
