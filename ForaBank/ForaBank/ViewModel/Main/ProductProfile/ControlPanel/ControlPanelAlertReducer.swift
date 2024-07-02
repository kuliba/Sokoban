//
//  ControlPanelAlertReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.07.2024.
//

import SwiftUI
import UIPrimitives

final class ControlPanelAlertReducer {
    
    private let productAlertsViewModel: ProductAlertsViewModel
    private let alertLifespan: DispatchTimeInterval

    init(
        alertLifespan: DispatchTimeInterval = .milliseconds(400),
        productAlertsViewModel: ProductAlertsViewModel
    ) {
        self.alertLifespan = alertLifespan
        self.productAlertsViewModel = productAlertsViewModel
    }
}

extension ControlPanelAlertReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        case let .delayAlert(kind):
            
            let alertViewModel: AlertModelOf<AlertEvent> = .init(
                title: productAlertsViewModel.title,
                message: productAlertsViewModel.message(by: kind),
                primaryButton: .init(type: .cancel, title: "ОК", event: .closeAlert))
                                
            effect = .delayAlert(alertViewModel, alertLifespan)
            
        case let .delayAlertViewModel(alertViewModel):
        
            effect = .delayAlertViewModel(alertViewModel, alertLifespan)
            
        case .closeAlert:
            state = nil
        case let .showAlert(alert):
            state = alert
        }
        return (state, effect)
    }
}

extension ControlPanelAlertReducer {
    
    typealias Event = AlertEvent
    typealias State = Alert.ViewModel?
    typealias Effect = ControlPanelFlowEffect
}
