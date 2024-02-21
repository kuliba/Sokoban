//
//  UtilityPaymentsReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public final class UtilityPaymentsReducer {
    
    private let observeLast: Int
    private let pageSize: Int
    
    public init(observeLast: Int, pageSize: Int) {
        
        self.observeLast = observeLast
        self.pageSize = pageSize
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
        
        effect = .paginate(operatorID, pageSize)
        
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
        _ result: LoadOperatorsResult
    ) -> (State, Effect?) {
        
        var state = state
        
        switch result {
        case let .failure(serviceFailure):
            state.status = .failure(serviceFailure)
            
        case let .success(paged):
            var operators = state.operators ?? []
            operators.append(contentsOf: paged)
            state.operators = operators
        }
        
        return (state, nil)
    }
    
    func reduce(
        _ state: State,
        _ event: Event.Search
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .entered(text):
            effect = .search(text)
            
        case let .updated(text):
            state.searchText = text
        }
        
        return (state, effect)
    }
}
