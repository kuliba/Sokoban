//
//  ControlPanelNavigationStateEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.07.2024.
//

import SwiftUI

final class ControlPanelNavigationStateEffectHandler {
    
    init(){}
}

extension ControlPanelNavigationStateEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .delayAlert(alert, dispatchTimeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                
                dispatch(.showAlert(alert))
            }
        case let .delayAlertViewModel(alert, dispatchTimeInterval):
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                
                dispatch(.showAlertViewModel(alert))
            }
        }
    }
}

extension ControlPanelNavigationStateEffectHandler {
    
    typealias Event = ControlPanelNavigationEvent
    typealias Effect = ControlPanelFlowEffect
    typealias Dispatch = (Event) -> Void
}

