//
//  StatefulLoaderReducer.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// A reducer that manages state transitions in the `StatefulLoader` based on incoming events.
public final class StatefulLoaderReducer {
    
    /// Initialises a new instance of the `StatefulLoaderReducer`.
    public init() {}
}

public extension StatefulLoaderReducer {
    
    /// Reduces the current state based on the given event and returns the new state and any triggered effect.
    /// - Parameters:
    ///   - state: The current state of the loader.
    ///   - event: The event that triggers a state transition.
    /// - Returns: A tuple containing the new state and an optional effect that was triggered.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
            
        case .loadFailure:
            state = .failed
            
        case .loadSuccess:
            state = .loaded
            
        case .reset:
            reset(&state, &effect)
        }
        
        return (state, effect)
    }
}

public extension StatefulLoaderReducer {
    
    /// Typealias for the possible states of the StatefulLoader.
    typealias State = StatefulLoaderState
    /// Typealias for the possible events that can trigger state changes.
    typealias Event = StatefulLoaderEvent
    /// Typealias for the possible effects that can be triggered.
    typealias Effect = StatefulLoaderEffect
}

private extension StatefulLoaderReducer {
    
    /// Handles the logic for transitioning to the `loading` state and triggering the `load` effect.
    /// - Parameters:
    ///   - state: The current state, which will be updated to `loading` if appropriate.
    ///   - effect: An optional effect that will be set to `load` if the transition occurs.
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        switch state {
        case .failed, .loaded, .notStarted:
            state = .loading
            effect = .load
            
        default:
            break
        }
    }
    
    /// Handles the logic for transitioning to the `notStarted` state when a reset event is triggered.
    /// - Parameters:
    ///   - state: The current state, which will be updated to `notStarted` if appropriate.
    ///   - effect: An optional effect, which is not used in this case.
    func reset(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        switch state {
        case .failed, .loaded:
            state = .notStarted
            
        default:
            break
        }
    }
}
