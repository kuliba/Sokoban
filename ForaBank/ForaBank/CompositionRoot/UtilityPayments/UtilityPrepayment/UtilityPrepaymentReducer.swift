//
//  UtilityPrepaymentReducer.swift
//
//
//  Created by Igor Malyarov on 09.05.2024.
//

final class UtilityPrepaymentReducer {}

extension UtilityPrepaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .didScrollTo(operatorID):
#warning("add event processing")
            
        case let .search(search):
            (state, effect) = reduce(state, search)
        }
        
        return (state, effect)
    }
}

extension UtilityPrepaymentReducer {
    
    typealias State = UtilityPrepaymentState
    typealias Event = UtilityPrepaymentEvent
    typealias Effect = UtilityPrepaymentEffect
}

private extension UtilityPrepaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event.Search
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .entered(text):
#warning("add event processing")
            
        case let .processed(text):
#warning("add event processing")
        }
        
        return (state, effect)
    }
}
