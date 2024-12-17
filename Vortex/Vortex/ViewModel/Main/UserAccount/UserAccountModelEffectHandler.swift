//
//  UserAccountModelEffectHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

import ManageSubscriptionsUI
import UserAccountNavigationComponent

final class UserAccountModelEffectHandler {
    
    let cancelC2BSub: (SubscriptionViewModel.Token) -> Void
    let deleteRequest: () -> Void
    let exit: () -> Void
    
    init(
        cancelC2BSub: @escaping (SubscriptionViewModel.Token) -> Void, 
        deleteRequest: @escaping () -> Void,
        exit: @escaping () -> Void
    ) {
        self.cancelC2BSub = cancelC2BSub
        self.deleteRequest = deleteRequest
        self.exit = exit
    }
}

extension UserAccountModelEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .cancelC2BSub(token):
            cancelC2BSub(token)
            
        case .deleteRequest:
            deleteRequest()
            
        case .exit:
            exit()
        }
    }
}

extension UserAccountModelEffectHandler {
    
    typealias Dispatch = (UserAccountEvent) -> Void
    
    typealias Effect = UserAccountEffect.ModelEffect
}
