//
//  UtilityPaymentsReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public final class UtilityPaymentsReducer {
    
    private let observeLast: Int
    
    public init(observeLast: Int) {
        
        self.observeLast = observeLast
    }
}

public extension UtilityPaymentsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .didScrollTo(operatorID):
            (state, effect) = reduce(state, operatorID)
            
        case .initiate:
            state.status = .inflight
            effect = .initiate
            
        case let .loaded(loaded):
            (state, effect) = reduce(state, loaded)
            
        case let .paginated(paginated):
            (state, effect) = reduce(state, paginated)
            
        case let .search(search):
            (state, effect) = reduce(state, search)
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
        _ operatorID: Operator.ID
    ) -> (State, Effect?) {
        
        var effect: Effect?
        
        guard let lastObserved = state.operators?.map(\.id).suffix(observeLast),
              Set(lastObserved).contains(operatorID)
        else { return (state, nil) }
        
        effect = .paginate
        
        return (state, effect)
    }
    
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
    
    func reduce(
        _ state: State,
        _ paginated: [Operator]
    ) -> (State, Effect?) {

        var operators = state.operators ?? []
        operators.append(contentsOf: paginated)
        var state = state
        state.operators = operators
        
        return (state, nil)
    }
    
    func reduce(
        _ state: State,
        _ event: Event.Search
    ) -> (State, Effect?) {

        #warning("FIX ME")
        
        return (state, nil)
    }
}
