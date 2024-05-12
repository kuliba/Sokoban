//
//  PrepaymentPickerReducer.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

public final class PrepaymentPickerReducer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let observeLast: Int
    private let pageSize: Int
    
    public init(
        observeLast: Int,
        pageSize: Int
    ) {
        self.observeLast = observeLast
        self.pageSize = pageSize
    }
}

public extension PrepaymentPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .didScrollTo(operatorID):
            reduce(&state, &effect, with: operatorID)
            
        case let .search(text):
            reduce(&state, &effect, with: text)
            
        case let .page(operators):
            reduce(&state, with: operators)
        }
        
        return (state, effect)
    }
}

public extension PrepaymentPickerReducer {
    
    typealias State = PrepaymentPickerState<LastPayment, Operator>
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

private extension PrepaymentPickerReducer {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with operatorID: Operator.ID
    ) {
        let lastObserved = state.operators.map(\.id).suffix(observeLast)
        
        guard Set(lastObserved).contains(operatorID),
              let last = state.operators.last
        else { return }
        
        effect = .paginate(.init(
            operatorID: last.id,
            pageSize: pageSize,
            searchText: state.searchText
        ))
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with text: String
    ) {
        guard !state.operators.isEmpty else { return }
        
        state.isSearching = true
        state.searchText = text
        effect = .paginate(.init(
            operatorID: nil,
            pageSize: pageSize,
            searchText: text
        ))
    }
    
    func reduce(
        _ state: inout State,
        with newOperators: [Operator]
    ) {
        if state.isSearching {
            state.isSearching = false
            state.operators = newOperators
        } else {
            var operators = state.operators
            operators.append(contentsOf: newOperators)
            state.operators = operators
        }
    }
}
