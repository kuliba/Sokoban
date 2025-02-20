//
//  LoadReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2025.
//

/// Reducer that handles state transitions based on load events.
public final class LoadReducer<Success, Failure: Error> {
    
    /// Initializes a new instance of `LoadReducer`.
    public init() {}
}

public extension LoadReducer {
    
    /// Transitions the state based on the given event.
    ///
    /// - Parameters:
    ///   - state: The current load state.
    ///   - event: The event to handle.
    /// - Returns: A tuple containing the updated state and an optional effect.
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            switch state {
            case let .completed(success):
                state = .loading(success)
                effect = .load
                
            case .failure:
                state = .loading(nil)
                effect = .load
                
            case .loading:
                break
                
            case .pending:
                state = .loading(nil)
                effect = .load
            }
            
        case let .loaded(result):
            switch result {
            case let .failure(failure):
                state = .failure(failure)
            case let .success(success):
                state = .completed(success)
            }
        }
        
        return (state, effect)
    }
}

public extension LoadReducer {
    
    /// Type alias for the state managed by `LoadReducer`.
    typealias State = LoadState<Success, Failure>
    /// Type alias for the events processed by `LoadReducer`.
    typealias Event = LoadEvent<Success, Failure>
    /// Type alias for the effects produced by `LoadReducer`.
    typealias Effect = LoadEffect
}
