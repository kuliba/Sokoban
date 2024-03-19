//
//  PaymentsTransfersFlowReducer.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public final class PaymentsTransfersFlowReducer<LastPayment, Operator, Service, StartPaymentResponse>
where Operator: Identifiable {
    
    private let utilityReduce: UtilityReduce
    
    public init(utilityReduce: @escaping UtilityReduce) {
        
        self.utilityReduce = utilityReduce
    }
}

public extension PaymentsTransfersFlowReducer {
    
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

public extension PaymentsTransfersFlowReducer {
    
    typealias UtilityReduce = (UtilityState, UtilityEvent) -> (UtilityState, UtilityEffect?)
    
    typealias UtilityState = Flow<Destination>
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias UtilityEffect = UtilityFlowEffect<LastPayment, Operator, Service>
    
    typealias Destination = UtilityDestination<LastPayment, Operator, Service>
    
    typealias State = PaymentsTransfersFlowState<Destination>
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
}

private extension PaymentsTransfersFlowReducer {
    
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
        case (.none, .initiatePrepayment):
            let (utilityFlow, utilityEffect) = utilityReduce(.init(), .initiatePrepayment)
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
