//
//  LoadableReducer.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

public final class LoadableReducer<Resource, Failure: Error> {
    
    public init() {}
}

public extension LoadableReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            state.status = .loading
            effect = .load
            
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
    
    typealias State = LoadableState<Resource, Failure>
    typealias Event = LoadableEvent<Resource, Failure>
    typealias Effect = LoadableEffect
}
