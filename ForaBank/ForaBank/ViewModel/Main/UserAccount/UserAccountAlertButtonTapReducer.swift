//
//  UserAccountAlertButtonTapReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.01.2024.
//

import UserAccountNavigationComponent

final class UserAccountAlertButtonTapReducer {}

extension UserAccountAlertButtonTapReducer {
    
    func reduce(
        _ state: State,
         _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .closeAlert:
            state.alert = nil
            
        case let .cancelC2BSub(token):
            effect = .model(.cancelC2BSub(token))
            
        case .delete:
            effect = .model(.deleteRequest)
            
        case .exit:
            effect = .model(.exit)
        }
        
        return (state, effect)
    }
}

extension UserAccountAlertButtonTapReducer {
    
    typealias State = UserAccountRoute
    typealias Event = UserAccountEvent.AlertButtonTap
    typealias Effect = UserAccountEffect
}
