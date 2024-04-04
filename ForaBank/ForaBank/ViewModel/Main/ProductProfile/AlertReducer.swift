//
//  AlertReducer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI

final class AlertReducer {
    
    let cvvAlertsViewModel: CvvAlertsViewModel
    
    init(
        cvvAlertsViewModel: CvvAlertsViewModel
    ) {
        self.cvvAlertsViewModel = cvvAlertsViewModel
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
            state = .init(title: cvvAlertsViewModel.title, message: cvvAlertsViewModel.blockAlertText, primary: .init(type: .cancel, title: "OK", action: {}))
        case .closeAlert:
            state = nil
        case .showAdditionalOtherAlert:
            state = .init(title: cvvAlertsViewModel.title, message: cvvAlertsViewModel.additionalAlertText, primary: .init(type: .cancel, title: "OK", action: {}))
        }
        
        return (state, effect)
    }
}

extension AlertReducer {
    
    typealias Event = AlertEvent
    typealias State = Alert.ViewModel?
    typealias Effect = Never
}
