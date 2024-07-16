//
//  PrepaymentSuccessPickerReducer.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

public final class PrepaymentSuccessPickerReducer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let observeLast: Int
    
    public init(
        observeLast: Int
    ) {
        self.observeLast = observeLast
    }
}

public extension PrepaymentSuccessPickerReducer {
    
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

public extension PrepaymentSuccessPickerReducer {
    
    typealias State = PrepaymentPickerSuccess<LastPayment, Operator>
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}

private extension PrepaymentPickerSuccess where Operator: Identifiable {
    
    mutating func append(
        _ operators: [Operator]
    ) {
        let existingIDs = Set(self.operators.map(\.id))
        let operators = operators.filter { !existingIDs.contains($0.id) }
        self.operators += operators
    }
    
    mutating func replace(
        _ operators: [Operator]
    ) {
        self.operators = operators
    }
}

private extension PrepaymentSuccessPickerReducer {
    
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
            searchText: state.searchText
        ))
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with text: String
    ) {
        state.searchText = text
        effect = .search(text)
    }
}
