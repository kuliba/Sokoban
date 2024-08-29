//
//  OperationTrackerReducer.swift
//
//
//  Created by Igor Malyarov on 27.08.2024.
//

/// A reducer that manages state transitions in the `OperationTracker` based on incoming events.
public final class OperationTrackerReducer {
    
    /// Initialises a new instance of the `OperationTrackerReducer`.
    public init() {}
}

public extension OperationTrackerReducer {
    
    /// Reduces the current state based on the given event and returns the new state and any triggered effect.
    /// - Parameters:
    ///   - state: The current state of the tracker.
    ///   - event: The event that triggers a state transition.
    /// - Returns: A tuple containing the new state and an optional effect that was triggered.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .fail:
            state = .failure
            
        case .reset:
            reset(&state, &effect)
            
        case .start:
            start(&state, &effect)
            
        case .succeed:
            state = .success
        }
        
        return (state, effect)
    }
}

public extension OperationTrackerReducer {
    
    /// Typealias for the possible states of the OperationTracker.
    typealias State = OperationTrackerState
    
    /// Typealias for the possible events that can trigger state changes.
    typealias Event = OperationTrackerEvent
    
    /// Typealias for the possible effects that can be triggered.
    typealias Effect = OperationTrackerEffect
}

private extension OperationTrackerReducer {
    
    /// Handles the logic for transitioning to the `inflight` state and triggering the `start` effect.
    /// - Parameters:
    ///   - state: The current state, which will be updated to `inflight` if appropriate.
    ///   - effect: An optional effect that will be set to `start` if the transition occurs.
    func start(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        switch state {
        case .failure, .success, .notStarted:
            state = .inflight
            effect = .start
            
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
        case .failure, .success:
            state = .notStarted
            
        default:
            break
        }
    }
}
