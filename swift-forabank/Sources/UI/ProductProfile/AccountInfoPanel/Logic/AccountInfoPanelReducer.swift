//
//  AccountInfoPanelReducer.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import Foundation

public final class AccountInfoPanelReducer {
    
    public init() {}
}

public extension AccountInfoPanelReducer {
 
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .appear:
            state.updateEvent(.appear)
            
        case let .buttonTapped(tap):
            switch tap {
                
            case let .accountDetails(card):
                state.updateEvent(.buttonTapped(.accountDetails(card)))
                
            case let .accountStatement(card):
                state.updateEvent(.buttonTapped(.accountStatement(card)))
            }
        }
        return (state, .none)
    }
}

public extension AccountInfoPanelReducer {
    
    typealias State = AccountInfoPanelState
    typealias Event = AccountInfoPanelEvent
    typealias Effect = AccountInfoPanelEffect

    typealias Reduce = (State, Event) -> (State, Effect?)
}
