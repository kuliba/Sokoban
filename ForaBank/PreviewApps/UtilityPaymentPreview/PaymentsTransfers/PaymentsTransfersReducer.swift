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
        
        switch event {
        case .openPrePayment:
            state.status = .inflight
            effect = .loadPrePayment
            
        case let .loaded(prePaymentResult):
            state.status = nil
            
            switch prePaymentResult {
            case let .failure(failure):
                state.prePayment = .failure(failure)

            case let .success(success):
                state.prePayment = .success(.selecting)
            }
            
        case .payByInstruction:
            #warning("FIX ME")
            break
            
        case .resetDestination:
            if state.prePayment != nil {
                state.prePayment = nil
            }
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {

    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
