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
        
        switch event {
        case .back:
            (state, effect) = back(state)
            
        case .openUtilityPayment:
            (state, effect) = openUtilityPayment(state)
            
        case let .utilityPayment(flowEvent):
            (state, effect) = reduce(state, flowEvent)
        }
        
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
    
    func back(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.route {
        case .none:
            break
            
        case let .utilityPayment(utilityPayment):
            switch utilityPayment.current {
            case .none:
                break
                
            case .prePaymentOptions:
                state.route = nil
                
            case .prePaymentState:
                let (s, e) = utilityPaymentFlowReduce(
                    utilityPayment,
                    .prePayment(.back)
                )
                state.route = .utilityPayment(s)
                effect = e.map { Effect.utilityPayment($0) }
            }
        }
        
        return (state, effect)
    }
    
    func openUtilityPayment(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.route {
        case .none:
#warning("`openUtilityPayment` could be `UtilityPaymentFlowEvent` case and this handling could be moved to `UtilityPaymentFlow` domain")
            state.status = .inflight
            state.route = .utilityPayment(.init([]))
            effect = .utilityPayment(.prePaymentOptions(.initiate))
            
        case .some:
            break
        }
            
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ flowEvent: FlowEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.route {
        case .none:
            break
            
        case let .utilityPayment(flowState):
            let (flowState, flowEffect) = utilityPaymentFlowReduce(flowState, flowEvent)
            state.route = .utilityPayment(flowState)
            state.status = flowState.isInflight ? .inflight : .none
            effect = flowEffect.map { Effect.utilityPayment($0) }
        }
        
        return (state, effect)
    }
}
