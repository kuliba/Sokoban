//
//  LoadableReducer.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Processes loading events to produce updated states and side effects.
///
/// The reducer is responsible for:
/// - Transitioning state in response to events
/// - Maintaining consistency of the resource state
/// - Creating appropriate effects for operations like loading
///
/// When processing a `load` event, it updates the state to loading and triggers
/// a load effect. For `loaded` events, it updates the state with the result.
/// Manages state transitions for a loadable resource.
public final class LoadableReducer<Resource, Failure: Error> {
    
    /// Initializes a new reducer instance.
    public init() {}
}

public extension LoadableReducer {
    
    /// Reduces the current state based on the received event and returns the updated state along with an optional effect.
    /// - Parameters:
    ///   - state: The current state before processing the event.
    ///   - event: The event triggering the state change.
    /// - Returns: A tuple containing the updated state and an optional effect.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            switch state.status {
            case.loading:
                break
            default:
                state.status = .loading
                effect = .load
            }
            
        case let .loaded(.failure(failure)):
            state.status = .failure(failure)
            
        case let .loaded(.success(loaded)):
            state.resource = loaded
            state.status = .loadedOK
        }
        
        return (state, effect)
    }
}

public extension LoadableReducer {
    
    /// Defines a type alias for the state managed by the reducer.
    typealias State = LoadableState<Resource, Failure>
    
    /// Defines a type alias for events that trigger state changes.
    typealias Event = LoadableEvent<Resource, Failure>
    
    /// Defines a type alias for effects that may be produced as a result of state transitions.
    typealias Effect = LoadableEffect
}
