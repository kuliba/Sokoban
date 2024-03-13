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
            
        case let .utilityFlow(flowEvent):
            (state, effect) = reduce(state, flowEvent)
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias PPState = PrePaymentState<LastPayment, Operator, UtilityService>
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
    typealias PPEffect = PrePaymentEffect<LastPayment, Operator, UtilityService>
    typealias PrePaymentReduce = (PPState, PPEvent) -> (PPState, PPEffect?)
    
    typealias FlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService>
    typealias FlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, PaymentsTransfersEvent.StartPayment, UtilityService>
    typealias FlowEffect = UtilityPaymentFlowEffect<LastPayment, Operator, UtilityService>
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
            
        case let .utilityFlow(utilityFlow):
            let (flowState, flowEffect) = utilityPaymentFlowReduce(
                utilityFlow,
                .back
            )
            
            if flowState.current == nil {
                state.route = nil
            } else {
                state.route = .utilityFlow(flowState)
                effect = flowEffect.map { .utilityPayment($0) }
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
            state.route = .utilityFlow(.init([]))
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
            
        case let .utilityFlow(flowState):
            let (flowState, flowEffect) = utilityPaymentFlowReduce(flowState, flowEvent)
            state.route = .utilityFlow(flowState)
            effect = flowEffect.map { .utilityPayment($0) }
            
            #warning("switch over flowState` to make additional state changes like go to chat if `addCompany`")
        }
        
        return (state, effect)
    }
}
