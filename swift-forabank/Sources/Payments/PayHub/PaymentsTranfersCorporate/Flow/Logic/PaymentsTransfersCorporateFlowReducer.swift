//
//  PaymentsTransfersCorporateFlowReducer.swift
//
//
//  Created by Andryusina Nataly on 12.09.2024.
//

public final class PaymentsTransfersCorporateFlowReducer {
    
    public init() {}
}

public extension PaymentsTransfersCorporateFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        }
        
        return (state, effect)
    }
}

public extension PaymentsTransfersCorporateFlowReducer {
    
    typealias State = PaymentsTransfersCorporateFlowState
    typealias Event = PaymentsTransfersCorporateFlowEvent
    typealias Effect = PaymentsTransfersCorporateFlowEffect
}
