//
//  AnywayPaymentReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import ForaTools

final class AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .otp(otp):
            state.elements[id: .widgetID(.otp)] = .widget(.otp(otp))
        }
        
        return (state, effect)
    }
}

extension AnywayPaymentReducer {
    
    typealias State = AnywayPayment
    typealias Event = AnywayEvent
    typealias Effect = AnywayEffect
}
