//
//  FlowReducer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

/// A reducer that manages the flow of state changes for a feature.
/// It takes an incoming `Event` and returns a new `State` along with an optional `Effect`.
public final class FlowReducer<Select, Navigation> {
    
    /// Creates a new instance of `FlowReducer`.
    public init() {}
}

public extension FlowReducer {
    
    /// Processes the given state and event, producing a new state and an optional side effect.
    /// - Parameters:
    ///   - state: The current state.
    ///   - event: The event that triggers state mutation.
    /// - Returns: A tuple containing the updated state and an optional effect.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.isLoading = false
            state.navigation = nil
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .navigation(navigation):
            state.isLoading = false
            state.navigation = navigation
            
        case let .select(select):
            state.isLoading = true
            state.navigation = nil
            effect = .select(select)
        }
        
        return (state, effect)
    }
}

public extension FlowReducer {
    
    /// The type representing the flow’s state.
    typealias State = FlowState<Navigation>
    
    /// The type representing all possible events handled by the flow.
    typealias Event = FlowEvent<Select, Navigation>
    
    /// The type representing any side effects triggered when handling an event.
    typealias Effect = FlowEffect<Select>
}
