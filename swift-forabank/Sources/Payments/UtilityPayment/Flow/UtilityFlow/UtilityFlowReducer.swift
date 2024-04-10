//
//  UtilityFlowReducer.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public final class UtilityFlowReducer<LastPayment, Operator, Service, StartPaymentResponse>
where Operator: Identifiable {
    
    private let ppoReduce: PPOReduce
    
    public init(
        ppoReduce: @escaping PPOReduce
    ) {
        self.ppoReduce = ppoReduce
    }
}

public extension UtilityFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .back:
            state.current = nil
            
        case .initiatePrepayment:
            if state.isEmpty {
                effect = .initiatePrepayment
            }
            
        case let .paymentStarted(result):
            state = reduce(state, result)
            
        case let .prepaymentLoaded(prepaymentLoaded):
            state = reduce(state, prepaymentLoaded)
            
        case let .prepaymentOptions(prepaymentOptions):
            (state, effect) = reduce(state, prepaymentOptions)
            
        case let .select(select):
            reduce(state, select, &effect)
            
        case let .selectFailure(`operator`):
            state.push(.selectFailure(`operator`))
            
        case let .servicesLoaded(services):
            state.push(.services(services))
        }
        
        return (state, effect)
    }
}

public extension UtilityFlowReducer {
    
    typealias PPOState = PrepaymentOptionsState<LastPayment, Operator>
    typealias PPOEvent = PrepaymentOptionsEvent<LastPayment, Operator>
    typealias PPOEffect = PrepaymentOptionsEffect<Operator>
    typealias PPOReduce = (PPOState, PPOEvent) -> (PPOState, PPOEffect?)

    typealias Destination = UtilityDestination<LastPayment, Operator, Service>
    
    typealias State = Flow<Destination>
    typealias Event = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator, Service>
}

private extension UtilityFlowReducer {
    
    func reduce(
        _ state: State,
        _ prepaymentLoaded: Event.PrepaymentLoaded
    ) -> State {
        
        var state = state
        
        if state.isEmpty {
            
            switch prepaymentLoaded {
            case .failure:
                state.current = .prepayment(.failure)
                
            case let .success(lastPayments, operators):
                state.push(.prepayment(.options(.init(
                    lastPayments: lastPayments,
                    operators: operators
                ))))
            }
        }
        
        return state
    }
    
    func reduce(
        _ state: State,
        _ prepaymentEvent: Event.OptionsEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        if case let .prepayment(.options(prepayment)) = state.current {
            
            let (s, e) = ppoReduce(prepayment, prepaymentEvent)
            state.current = .prepayment(.options(s))
            effect = e.map { .prepaymentOptions($0) }
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ result: Event.StartPaymentResult
    ) -> State {
        
        var state = state
        
        switch result {
        case let .failure(serviceFailure):
            state.push(.failure(serviceFailure))
            
        case let .success(response):
            state.push(.payment)
        }
        
        return state
    }
    
    func reduce(
        _ state: State,
        _ select: Event.Select,
        _ effect: inout Effect?
    ) {
        switch select {
        case .last, .operator:
            if case .prepayment = state.current {
                
                effect = .select(select.effectSelect)
            }
            
        case let .service(service, for: `operator`):
            if case .services = state.current {
                
                effect = .select(.service(service, for: `operator`))
            }
        }
    }
}

private extension UtilityFlowEvent.Select {
    
    var effectSelect: UtilityFlowEffect<LastPayment, Operator, Service>.Select {
        
        switch self {
        case let .last(lastPayment):
            return .last(lastPayment)
            
        case let .operator(`operator`):
            return .operator(`operator`)
            
        case let .service(service, for: `operator`):
            return .service(service, for: `operator`)
        }
    }
}
