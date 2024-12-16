//
//  PrepaymentPickerReducer.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import UtilityServicePrepaymentDomain

public final class PrepaymentPickerReducer<LastPayment, Operator>
where Operator: Identifiable {
    
    private let successReduce: SuccessReduce
    
    public init(
        successReduce: @escaping SuccessReduce
    ) {
        self.successReduce = successReduce
    }
}

public extension PrepaymentPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        guard case let .success(success) = state
        else { return (state, effect) }
        
        let (newSuccess, successEffect) = successReduce(success, event)
        state = .success(newSuccess)
        effect = successEffect

        return (state, effect)
    }
}

public extension PrepaymentPickerReducer {
    
    typealias Success = PrepaymentPickerSuccess<LastPayment, Operator>
    typealias SuccessReduce = (Success, Event) -> (Success, Effect?)
    
    typealias State = PrepaymentPickerState<LastPayment, Operator>
    typealias Event = PrepaymentPickerEvent<Operator>
    typealias Effect = PrepaymentPickerEffect<Operator.ID>
}
