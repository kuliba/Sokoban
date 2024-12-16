//
//  AnywayPaymentContextReducer.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import AnywayPaymentDomain

public final class AnywayPaymentContextReducer {
    
    private let anywayPaymentReduce: AnywayPaymentReduce
    
    public init(
        anywayPaymentReduce: @escaping AnywayPaymentReduce
    ) {
        self.anywayPaymentReduce = anywayPaymentReduce
    }
}

public extension AnywayPaymentContextReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        let (payment, _) = anywayPaymentReduce(state.payment, event)
        state.payment = payment
        
        return (state, effect)
    }
}

public extension AnywayPaymentContextReducer {
    
    typealias State = AnywayPaymentContext
    typealias Event = AnywayPaymentEvent
    typealias Effect = AnywayPaymentEffect
    
    typealias AnywayPaymentReduce = (AnywayPayment, Event) -> (AnywayPayment, Effect?)
}

