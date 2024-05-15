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
            
        case let .load(operators):
            state.replace(operators)
            
        case let .page(operators):
            state.append(operators)
            
        case let .search(text):
            reduce(&state, &effect, with: text)
        }
        
        return (state, effect)
    }
}

public extension PrepaymentPickerReducer {
    
    typealias State = PrepaymentPickerState<LastPayment, Operator>
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

private extension PrepaymentPickerState {
    
    mutating func append(
        _ operators: [Operator]
    ) {
        let operators = self.operators + operators
        self.operators = operators
    }
    
    mutating func replace(
        _ operators: [Operator]
    ) {
        self.operators = operators
    }
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
        state.searchText = text
        effect = .search(.init(
            pageSize: pageSize,
            searchText: text
        ))
    }
}
