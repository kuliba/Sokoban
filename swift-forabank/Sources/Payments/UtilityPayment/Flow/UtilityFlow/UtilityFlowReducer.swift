//
//  UtilityFlowReducer.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public final class UtilityFlowReducer<LastPayment, Operator, Service, StartPaymentResponse> {
    
    public init() {}
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
            
        case let .loaded(loaded):
            state = reduce(state, loaded)
            
        case let .loadedServices(services):
            state.push(.services(services))
            
        case let .paymentStarted(result):
            state = reduce(state, result)
            
        case let .select(select):
            reduce(state, select, &effect)
            
        case let .selectFailure(`operator`):
            state.push(.selectFailure(`operator`))
        }
        
        return (state, effect)
    }
}

public extension UtilityFlowReducer {
    
    typealias Destination = UtilityDestination<LastPayment, Operator, Service>
    
    typealias State = Flow<Destination>
    typealias Event = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator, Service>
}

private extension UtilityFlowReducer {
    
    func reduce(
        _ state: State,
        _ loaded: Event.Loaded
    ) -> State {
        
        var state = state
        
        if state.isEmpty {
            
            switch loaded {
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
