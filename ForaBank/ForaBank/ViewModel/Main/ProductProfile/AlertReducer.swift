//
//  AlertReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI

final class AlertReducer {
    
    let productAlertsViewModel: ProductAlertsViewModel
    
    init(
        productAlertsViewModel: ProductAlertsViewModel
    ) {
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
        case .showBlockAlert:
            state = .init(title: productAlertsViewModel.title, message: productAlertsViewModel.blockAlertText, primary: .init(type: .cancel, title: "OK", action: {}))
        case .closeAlert:
            state = nil
        case .showAdditionalOtherAlert:
            state = .init(title: productAlertsViewModel.title, message: productAlertsViewModel.additionalAlertText, primary: .init(type: .cancel, title: "OK", action: {}))
        }
        
        return (state, effect)
    }
}

extension AlertReducer {
    
    typealias Event = AlertEvent
    typealias State = Alert.ViewModel?
    typealias Effect = Never
}
