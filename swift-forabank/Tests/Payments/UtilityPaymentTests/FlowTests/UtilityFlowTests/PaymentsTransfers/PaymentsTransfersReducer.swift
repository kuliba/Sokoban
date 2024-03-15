//
//  PaymentsTransfersReducer.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

final class PaymentsTransfersReducer<LastPayment, Operator> {
    
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
            
        case let .start(flow):
            (state, effect) = start(state, flow)
            
        case let .utilityFlow(utilityFlow):
            fatalError()
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias UtilityReduce = (UtilityState, UtilityEvent) -> (UtilityState, UtilityEffect?)
    
    typealias UtilityState = Flow<Destination>
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator>
    typealias UtilityEffect = UtilityFlowEffect
    
    typealias Destination = UtilityDestination<LastPayment, Operator>
    
    typealias State = PaymentsTransfersState<Destination>
    typealias Event = PaymentsTransfersEvent<LastPayment, Operator>
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
    
    func start(
        _ state: State,
        _ flow: Event.Flow
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch flow {
        case .utilityFlow:
            (state, effect) = startUtilityFlow(state)
        }
        
        return (state, effect)
    }
    
    func startUtilityFlow(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
            
        let (utilityFlow, utilityEffect) = utilityReduce(
            state.utilityFlow ?? .init(),
            .initiate
        )
        state.route = .utilityFlow(utilityFlow)
        effect = utilityEffect.map { .utilityFlow($0) }
        
        return (state, effect)
    }
}

private extension Flow {
    
    var isEmpty: Bool { stack.isEmpty }
}

private extension PaymentsTransfersState {
    
    var utilityFlow: Route.UtilityFlow? {
        
        guard case let .utilityFlow(utilityFlow) = route
        else { return nil }
        
        return utilityFlow
    }
}
