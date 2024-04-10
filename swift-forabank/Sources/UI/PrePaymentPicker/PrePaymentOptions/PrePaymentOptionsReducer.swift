//
//  PrePaymentOptionsReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

@available(*, deprecated, message: "Use `PrepaymentOptionsReducer` from `UtilityPayment` module")
public final class PrePaymentOptionsReducer<LastPayment, Operator>
where LastPayment: Equatable & Identifiable,
      Operator: Equatable & Identifiable {
    
    private let observeLast: Int
    private let pageSize: Int
    
    public init(observeLast: Int, pageSize: Int) {
        
        self.observeLast = observeLast
        self.pageSize = pageSize
    }
}

public extension PrePaymentOptionsReducer {
    
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
            state.isInflight = true
            effect = .initiate
            
        case let .loaded(latestPayments, operators):
            (state, effect) = reduce(state, latestPayments, operators)
            
        case let .paginated(paginated):
            (state, effect) = reduce(state, paginated)
            
        case let .search(search):
            (state, effect) = reduce(state, search)
        }
        
        return (state, effect)
    }
}

public extension PrePaymentOptionsReducer {
    
    typealias State = PrePaymentOptionsState<LastPayment, Operator>
    typealias Event = PrePaymentOptionsEvent<LastPayment, Operator>
    typealias Effect = PrePaymentOptionsEffect<Operator>
}

private extension PrePaymentOptionsReducer {
    
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
        _ latestPayments: Event.LoadLastPaymentsResult,
        _ operators: Event.LoadOperatorsResult
    ) -> (State, Effect?) {
        
        var state = state
        
        state.lastPayments = try? latestPayments.get()
        state.operators = try? operators.get()
        state.isInflight = false
        
        return (state, nil)
    }
    
    func reduce(
        _ state: State,
        _ result: Event.LoadOperatorsResult
    ) -> (State, Effect?) {
        
        var state = state
        
        var operators = state.operators ?? []
        let paged = try? result.get()
        operators.append(contentsOf: paged ?? [])
        state.operators = operators
        state.isInflight = false
        
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
