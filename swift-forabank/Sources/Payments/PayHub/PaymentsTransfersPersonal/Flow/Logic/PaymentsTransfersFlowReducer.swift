//
//  PaymentsTransfersFlowReducer.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public final class PaymentsTransfersFlowReducer {
    
    public init() {}
}

public extension PaymentsTransfersFlowReducer {
    
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

public extension PaymentsTransfersFlowReducer {
    
    typealias State = PaymentsTransfersFlowState
    typealias Event = PaymentsTransfersFlowEvent
    typealias Effect = PaymentsTransfersFlowEffect
}
