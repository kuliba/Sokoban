//
//  LoadableReducer.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

final class LoadableReducer<Resource, Failure: Error> {
    
    init() {}
}

extension LoadableReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            state.result = nil
            effect = .load
            
        case let .loaded(.failure(failure)):
            break
            
        case let .loaded(.success(loaded)):
            state.resource = loaded
            state.result = .success(.init())
        }
        
        return (state, effect)
    }
}

extension LoadableReducer {
    
    typealias State = LoadableState<Resource, Failure>
    typealias Event = LoadableEvent<Resource, Failure>
    typealias Effect = LoadableEffect
}
