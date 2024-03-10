//
//  PaymentsTransfersReducer.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

final class PaymentsTransfersReducer {
    
    private let utilityPaymentFlowReduce: UtilityPaymentFlowReduce
    
    init(
        utilityPaymentFlowReduce: @escaping UtilityPaymentFlowReduce
    ) {
        self.utilityPaymentFlowReduce = utilityPaymentFlowReduce
    }
}

extension PaymentsTransfersReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state.route, event) {
        case (.none, .openUtilityPayment):
            state.status = .inflight
            state.route = .utilityPayment(.init([]))
            effect = .utilityPayment(.prePaymentOptions(.initiate))
            
//        case let (.none, .utilityPayment(.prePaymentOptions(.loaded(loadLastPaymentsResult, loadOperatorsResult)))):
//            fatalError("loaded")
            
        case let (.utilityPayment(flowState), .utilityPayment(flowEvent)):
            (state, effect) = reduce(state, flowState, flowEvent)
            
        default:
            fatalError("can't handle \(event) at \(state)")
        }
        
        //        switch event {
        //        case .openPrePayment:
        //            state.status = .inflight
        //            effect = .loadPrePayment
        //
        //        case let .loaded(prePaymentResult):
        //            state.status = nil
        //
        //            switch prePaymentResult {
        //            case let .failure(failure):
        //                state.route = .prePayment(.failure(failure))
        //
        //            case let .success(success):
        //                state.route = .prePayment(.success(.selecting))
        //            }
        //
        //        case let .loadedServices(response, for: `operator`):
        //            switch response {
        //
        //            case .failure:
        //                fatalError()
        //
        //            case let .list(utilityServices):
        //                fatalError()
        //
        //            case let .single(utilityService):
        //                state.status = .inflight
        //                effect = .startPayment(.service(`operator`, utilityService))
        //            }
        //
        //        case .payByInstruction:
        //#warning("FIX ME")
        //
        //        case let .prePayment(prePaymentEvent):
        //
        //            if prePaymentEvent == .back,
        //               case let .utilityPayment(utilityPayment) = state.route {
        //
        //                // state.route = .prePayment(.success(utilityPayment.prePayment))
        //                break
        //            }
        //
        //#warning("what if it's failure case?")
        //            guard case let .prePayment(.success(prePaymentState)) = state.route
        //            else { break }
        //
        //            let (newPrePaymentState, _) = prePaymentReduce(prePaymentState, prePaymentEvent)
        //            state.route = .prePayment(.success(newPrePaymentState))
        //
        //            switch newPrePaymentState {
        //            case let .selected(.last(lastPayment)):
        //                state.status = .inflight
        //                effect = .startPayment(.last(lastPayment))
        //
        //            case let .selected(.operator(`operator`)):
        //                state.status = .inflight
        //                effect = .loadServices(for: `operator`)
        //
        //            default:
        //                break
        //            }
        //
        //        case .resetDestination:
        //            state.route = nil
        //
        //        case let .startPaymentResponse(response):
        //            guard case let .prePayment(.success(prePayment)) = state.route
        //            else { break }
        //
        //            state.status = nil
        //#warning("FIX ME")
        //            switch response {
        //            case let .failure(serviceFailure):
        //#warning("move to mainScreen")
        //                print("startPaymentResponse: \(serviceFailure)")
        //
        //            case let .success(startPayment):
        //                // state.route = .utilityPayment(.init(prePayment: prePayment))
        //                break
        //            }
        //        }
        
        dump(state)
        dump(effect)
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias PPState = PrePaymentState<LastPayment, Operator>
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
    typealias PPEffect = PrePaymentEffect<LastPayment, Operator>
    typealias PrePaymentReduce = (PPState, PPEvent) -> (PPState, PPEffect?)
    
    typealias FlowState = UtilityPaymentFlowState<LastPayment, Operator>
    typealias FlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
    typealias FlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator>
    typealias UtilityPaymentFlowReduce = (FlowState, FlowEvent) -> (FlowState, FlowEffect?)
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersReducer {
    
    func reduce(
        _ state: State,
        _ flowState: FlowState,
        _ flowEvent: FlowEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        let (flowState, flowEffect) = utilityPaymentFlowReduce(flowState, flowEvent)
        
        state.status = .none
        state.route = .utilityPayment(flowState)
        if flowState.isInflight {
            state.status = .inflight
        }
        
        effect = flowEffect.map { Effect.utilityPayment($0) }
        
        return (state, effect)
    }
}
