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
            
        case let .loadedServices(response, for: `operator`):
            switch response {
                
            case .failure:
                fatalError()
                
            case let .list(utilityServices):
                fatalError()
                
            case let .single(utilityService):
                state.status = .inflight
                effect = .startPayment(.service(`operator`, utilityService))
            }
            
        case .payByInstruction:
            print("payByInstruction event")
#warning("FIX ME")
            
        case let .prePayment(prePaymentEvent):
            print("prePaymentEvent event: \(prePaymentEvent)")
            #warning("what if it's failure case?")
            guard case let .success(prePaymentState) = state.prePayment
            else { break }
            
            let (newPrePaymentState, _) = prePaymentReduce(prePaymentState, prePaymentEvent)
            state.prePayment = .success(newPrePaymentState)
            
            switch newPrePaymentState {
            case let .selected(.last(lastPayment)):
                state.status = .inflight
                effect = .startPayment(.last(lastPayment))
                
            case let .selected(.operator(`operator`)):
                state.status = .inflight
                effect = .loadServices(for: `operator`)
                
            default:
                break
            }
            
        case .resetDestination:
            if state.prePayment != nil {
                state.prePayment = nil
            }
            
        case let .startPaymentResponse(response):
            state.status = nil
            #warning("FIX ME")
            switch response {
            case let .failure(serviceFailure):
                print("startPaymentResponse: \(serviceFailure)")
                
            case let .success(startPayment):
                print("startPaymentResponse: \(startPayment)")
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
