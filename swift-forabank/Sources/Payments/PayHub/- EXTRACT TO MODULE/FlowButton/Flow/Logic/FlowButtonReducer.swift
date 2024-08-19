//
//  FlowButtonReducer.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

public final class FlowButtonReducer<Destination> {
    
    public init() {}
}

public extension FlowButtonReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .buttonTap:
            effect = .processButtonTap
            
        case .dismissDestination:
            state.destination = nil
            
        case let .setDestination(destination):
            state.destination = destination
        }
        
        return (state, effect)
    }
}

public extension FlowButtonReducer {
    
    typealias State = FlowButtonState<Destination>
    typealias Event = FlowButtonEvent<Destination>
    typealias Effect = FlowButtonEffect
}
