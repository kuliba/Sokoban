//
//  AlertReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI

final class AlertReducer {
    
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

extension AlertReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
            
        case let .delayAlert(kind):
            
            let alertViewModel: Alert.ViewModel = .init(
                title: productAlertsViewModel.title,
                message: productAlertsViewModel.message(by: kind),
                primary: .init(type: .cancel, title: "OK", action: {}))
        
            effect = .delayAlert(alertViewModel, alertLifespan)
            
        case let .delayAlertViewModel(alertViewModel):
        
            effect = .delayAlert(alertViewModel, alertLifespan)
            
        case .closeAlert:
            state = nil
        case let .showAlert(alert):
            state = alert
        }
        return (state, effect)
    }
}

extension AlertReducer {
    
    typealias Event = AlertEvent
    typealias State = Alert.ViewModel?
    typealias Effect = ProductProfileFlowEffect
}

extension ProductAlertsViewModel {
    
    func message(by kind: AlertEvent.Kind) -> String {
        
        switch kind {
        case .showBlockAlert:
            return blockAlertText
        case .showAdditionalOtherAlert:
            return additionalAlertText
        case .showServiceOnlyMainCard:
            return serviceOnlyMainCard
        case .showServiceOnlyOwnerCard:
            return serviceOnlyOwnerCard
        case .showTransferAdditionalOther:
            return transferAdditionalOther
        case .showServiceOnlyIndividualCard:
            return serviceOnlyIndividualCard
        }
    }
}
