//
//  PaymentsTransfersReducer.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

final class PaymentsTransfersReducer {
    
}

extension PaymentsTransfersReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {

    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
