//
//  UtilityFlowReducer.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

final class UtilityFlowReducer<LastPayment, Operator, Service, StartPaymentResponse> {
    
}

extension UtilityFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .back:
            state.current = nil
            
        case .initiate:
            if state.current == nil {
                effect = .initiate
            }
            
        case let .loaded(loaded):
            if state.current == nil {
                
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
            
        case let .loadedServices(services):
            fatalError()
            
        case let .paymentStarted(result):
            switch result {
            case let .failure(serviceFailure):
                state.push(.failure(serviceFailure))
                
            case let .success(response):
                state.push(.payment)
            }
            
        case let .select(select):
            if case .prepayment = state.current {
                
                effect = .select(select.effectSelect)
            }
            
        case let .selectFailure(`operator`):
            fatalError()
        }
        
        return (state, effect)
    }
}

private extension UtilityFlowEvent.Select {
    
    var effectSelect: UtilityFlowEffect<LastPayment, Operator>.Select {
        
        switch self {
        case let .last(lastPayment):
            return .last(lastPayment)
            
        case let .operator(`operator`):
            return .operator(`operator`)
        }
    }
}

extension UtilityFlowReducer {
    
    typealias Destination = UtilityDestination<LastPayment, Operator>
    
    typealias State = Flow<Destination>
    typealias Event = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator>
}
