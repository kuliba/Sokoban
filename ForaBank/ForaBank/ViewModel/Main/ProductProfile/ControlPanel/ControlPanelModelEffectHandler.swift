//
//  ControlPanelModelEffectHandler.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 22.07.2024.
//

import ManageSubscriptionsUI

final class ControlPanelModelEffectHandler {
    
    let cancelC2BSub: (SubscriptionViewModel.Token) -> Void
    
    init(
        cancelC2BSub: @escaping (SubscriptionViewModel.Token) -> Void
    ) {
        self.cancelC2BSub = cancelC2BSub
    }
}

extension ControlPanelModelEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .cancelC2BSub(token):
            cancelC2BSub(token)
        }
    }
}

extension ControlPanelModelEffectHandler {
    
    typealias Dispatch = (ControlPanelEvent) -> Void
    
    typealias Effect = ControlPanelEffect.ModelEffect
}
