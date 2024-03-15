//
//  PaymentsTransfersReducer.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

final class PaymentsTransfersReducer<LastPayment, Operator, Service, StartPaymentResponse> {
    
    private let utilityReduce: UtilityReduce
    
    init(utilityReduce: @escaping UtilityReduce) {
        
        self.utilityReduce = utilityReduce
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
            
        case let .utilityFlow(utilityFlowEvent):
            (state, effect) = reduce(state, utilityFlowEvent)
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias UtilityReduce = (UtilityState, UtilityEvent) -> (UtilityState, UtilityEffect?)
    
    typealias UtilityState = Flow<Destination>
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias UtilityEffect = UtilityFlowEffect<LastPayment, Operator>
    
    typealias Destination = UtilityDestination<LastPayment, Operator>
    
    typealias State = PaymentsTransfersState<Destination>
    typealias Event = PaymentsTransfersEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = PaymentsTransfersEffect<LastPayment, Operator>
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
            let (utilityFlow, utilityEffect) = utilityReduce(utilityFlow, .back)
            if utilityFlow.isEmpty {
                state.route = nil
            } else {
                state.route = .utilityFlow(utilityFlow)
                effect = utilityEffect.map { .utilityFlow($0) }
            }
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: Event.UtilityFlow
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (state.route, event) {
        case (.none, .initiate):
            let (utilityFlow, utilityEffect) = utilityReduce(.init(), .initiate)
            state.route = .utilityFlow(utilityFlow)
            effect = utilityEffect.map { .utilityFlow($0) }
            
        case let (.utilityFlow(utilityFlow), _):
            let (utilityFlow, utilityEffect) = utilityReduce(utilityFlow, event)
            state.route = .utilityFlow(utilityFlow)
            effect = utilityEffect.map { .utilityFlow($0) }
            
        default:
            break
        }
        
        return (state, effect)
    }
}

private extension Flow {
    
    var isEmpty: Bool { stack.isEmpty }
}
