//
//  OrderSavingsAccountReducer.swift
//
//
//  Created by Andryusina Nataly on 06.02.2025.
//

import Foundation

public final class OrderSavingsAccountReducer {
    
    let openURL: (URL) -> Void
    
    public init(
        openURL: @escaping (URL) -> Void
    ) {
        self.openURL = openURL
    }
}

public extension OrderSavingsAccountReducer {
    
    // TODO: add tests
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .continue:
            state.isShowingOTP = true
            effect = .prepareAccount
            
        case let .amount(amountEvent):
            switch amountEvent {
            case let .edit(newValue):
                state.amountValue = newValue
                
            case .pay:
                state.isShowingOTP = true
                effect = .prepareAccount
            }
            
        case .consent:
            state.consent.toggle()
            
        case let .openURL(url):
            openURL(url)
        }
        return (state, effect)
    }
}

public extension OrderSavingsAccountReducer {
    
    typealias State = OrderSavingsAccountState
    typealias Event = OrderSavingsAccountEvent
    typealias Effect = OrderSavingsAccountEffect
}
