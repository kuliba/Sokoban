//
//  PrepaymentPickerReducer.swift
//  
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

final class PrepaymentPickerReducer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let observeLast: Int
    private let pageSize: Int
    
    init(
        observeLast: Int,
        pageSize: Int
    ) {
        self.observeLast = observeLast
        self.pageSize = pageSize
    }
}

extension PrepaymentPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .didScrollTo(operatorID):
            reduce(&state, &effect, with: operatorID)
            
        case let .page(operators):
            reduce(&state, with: operators)
        }
        
        return (state, effect)
    }
}

extension PrepaymentPickerReducer {
    
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
        
        guard Set(lastObserved).contains(operatorID) else { return }
        
        effect = .paginate(operatorID, pageSize)
    }
    
    func reduce(
        _ state: inout State,
        with newOperators: [Operator]
    ) {
        var operators = state.operators
        operators.append(contentsOf: newOperators)
        state.operators = operators
    }
}
