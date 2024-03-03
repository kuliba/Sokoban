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
                print(failure)

            case let .success(success):
                print(success)
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
