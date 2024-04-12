//
//  AnywayPaymentReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore

final class AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        let state = state
        let effect: Effect?
        
        switch event {
            
        }
        
        return (state, effect)
    }
}

extension AnywayPaymentReducer {
    
    typealias State = AnywayPayment
    typealias Event = AnywayEvent
    typealias Effect = AnywayEffect
}
