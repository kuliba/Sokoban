//
//  PaymentsTransfersReducer.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

final class PaymentsTransfersReducer {
    
    private let prePaymentReduce: PrePaymentReduce
    
    init(prePaymentReduce: @escaping PrePaymentReduce) {
        
        self.prePaymentReduce = prePaymentReduce
    }
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
            print("payByInstruction event")
#warning("FIX ME")
            
        case let .prePayment(prePaymentEvent):
            print("prePaymentEvent event: \(prePaymentEvent)")
            guard case let .success(prePaymentState) = state.prePayment
            else { break }
            
            let (newPrePaymentState, prePaymentEffect) = prePaymentReduce(prePaymentState, prePaymentEvent)
#warning("FIX ME")
            
        case .resetDestination:
            if state.prePayment != nil {
                state.prePayment = nil
            }
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias PrePaymentReduce = (PrePaymentState, PrePaymentEvent) -> (PrePaymentState, PrePaymentEffect?)
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
