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
                state.route = .prePayment(.failure(failure))
                
            case let .success(success):
                state.route = .prePayment(.success(.selecting))
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
#warning("FIX ME")
            
        case let .prePayment(prePaymentEvent):
            
            if prePaymentEvent == .back,
                case let .utilityPayment(utilityPayment) = state.route {
                
                state.route = .prePayment(.success(utilityPayment.prePayment))
                break
            }
            
            #warning("what if it's failure case?")
            guard case let .prePayment(.success(prePaymentState)) = state.route
            else { break }
            
            let (newPrePaymentState, _) = prePaymentReduce(prePaymentState, prePaymentEvent)
            state.route = .prePayment(.success(newPrePaymentState))
            
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
            state.route = nil
            
        case let .startPaymentResponse(response):
            guard case let .prePayment(.success(prePayment)) = state.route
            else { break }
            
            state.status = nil
            #warning("FIX ME")
            switch response {
            case let .failure(serviceFailure):
                #warning("move to mainScreen")
                print("startPaymentResponse: \(serviceFailure)")
                
            case let .success(startPayment):
                state.route = .utilityPayment(.init(prePayment: prePayment))
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
