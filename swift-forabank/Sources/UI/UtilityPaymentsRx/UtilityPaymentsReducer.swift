//
//  UtilityPaymentsReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public final class UtilityPaymentsReducer {
    
    public init() {}
}

public extension UtilityPaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .initiate:
            state.status = .inflight
            effect = .initiate
            
        case let .loaded(loaded):
            (state, effect) = reduce(state, loaded)
        }
        
        return (state, effect)
    }
}

public extension UtilityPaymentsReducer {
    
    typealias State = UtilityPaymentsState
    typealias Event = UtilityPaymentsEvent
    typealias Effect = UtilityPaymentsEffect
}

private extension UtilityPaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event.Loaded
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .lastPayments(loadLastPaymentsResult):
            switch loadLastPaymentsResult {
            case let .failure(serviceFailure):
                state.status = .failure(serviceFailure)
                
            case let .success(lastPayments):
                state.status = nil
                state.lastPayments = lastPayments
            }
            
        case let .operators(loadOperatorsResult):
            switch loadOperatorsResult {
            case let .failure(serviceFailure):
                state.status = .failure(serviceFailure)
                
            case let .success(operators):
                state.status = nil
                state.operators = operators
            }
        }
        
        return (state, nil)
    }
}
