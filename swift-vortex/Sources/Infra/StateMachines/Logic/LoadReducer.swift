//
//  LoadReducer.swift
//
//
//  Created by Igor Malyarov on 19.02.2025.
//

/// A reducer that manages state transitions for loadable resources.
/// It processes load events and produces updated load states along with optional side effects.
public final class LoadReducer<Success, Failure: Error> {
    
    private let canReload: Bool
    
    /// Creates a new instance of `LoadReducer`.
    ///
    /// - Parameter canReload: A Boolean value indicating whether the reducer allows reloading
    ///   after a successful load. Defaults to `true`.
    public init(canReload: Bool = true) {
        
        self.canReload = canReload
    }
}

public extension LoadReducer {
    
    /// Processes a load event and transitions the current load state accordingly.
    /// Depending on the current state and the event received, an optional side effect (`Effect`)
    /// may be produced.
    ///
    /// - Parameters:
    ///   - state: The current load state.
    ///   - event: The event to process.
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
                if canReload {
                    state = .loading(success)
                    effect = .load
                }
                
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
    
    /// The state type managed by `LoadReducer`.
    typealias State = LoadState<Success, Failure>
    
    /// The event type processed by `LoadReducer`.
    typealias Event = LoadEvent<Success, Failure>
    
    /// The effect type produced by `LoadReducer`.
    typealias Effect = LoadEffect
}
