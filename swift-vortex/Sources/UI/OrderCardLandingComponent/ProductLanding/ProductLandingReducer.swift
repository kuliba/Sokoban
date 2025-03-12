//
//  LandProductLandingReduceringReducer.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import Foundation

public final class ProductLandingReducer<Landing> {
    
    public init() {}
}

public extension ProductLandingReducer {
    
    func reduce(
        _ state: State,
        event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismissInformer:
            dismissInformer(&state)
            
        case .load:
            if !state.isLoading {
                
                state.isLoading = true
                effect = .load
            }
            
        case let .loadResult(result):
            update(&state, with: result)
        }
        
        return (state, effect)
    }
    
    typealias State = LandingState<Landing>
    typealias Event = LandingEvent<Landing>
    typealias Effect = LandingEffect
}

private extension ProductLandingReducer {
    
    func update(
        _ state: inout State,
        with result: (Result<Landing, LoadFailure>)
    ) {
        state.isLoading = false
        
        switch result {
        case let .success(landing):
            state.status = .landing(landing)
            
        case let .failure(failure):
            switch state.status {
            case let .landing(landing):
                state.status = .mix(landing, failure)
                
            case .failure:
                state.status = .failure(failure)
                
            case let .mix(landing, _):
                state.status = .mix(landing, failure)
                
            case .none:
                state.status = .failure(failure)
            }
        }
    }
    
    func dismissInformer(
        _ state: inout State
    ) {
        switch state.status {
        case let .failure(failure):
            switch failure.type {
            case .alert:
                break
            case .informer:
                state.status = nil
            }
            
        case let .mix(landing, failure):
            switch failure.type {
            case .alert:
                break
            case .informer:
                state.status = .landing(landing)
            }
            
        default:
            break
        }
    }
}
