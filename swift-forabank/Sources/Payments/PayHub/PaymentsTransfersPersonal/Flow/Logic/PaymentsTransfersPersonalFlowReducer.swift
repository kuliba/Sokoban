//
//  PaymentsTransfersPersonalFlowReducer.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

public final class PaymentsTransfersPersonalFlowReducer {
    
    public init() {}
}

public extension PaymentsTransfersPersonalFlowReducer {
    
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

public extension PaymentsTransfersPersonalFlowReducer {
    
    typealias State = PaymentsTransfersPersonalFlowState
    typealias Event = PaymentsTransfersPersonalFlowEvent
    typealias Effect = PaymentsTransfersPersonalFlowEffect
}
