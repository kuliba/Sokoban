//
//  LandingReducer.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 03.03.2025.
//

import Foundation
import OrderCard

final class LandingReducer<Landing> {
    
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
            //TODO: extract to method
            state.isLoading = false
            
            updateResult(result, &state)
        }
        
        return (state, effect)
    }
    
    typealias State = OrderCardLandingDomain.LandingState<Landing>
    typealias Event = OrderCardLandingDomain.LandingEvent<Landing>
    typealias Effect = OrderCardLandingDomain.LandingEffect
}

extension LandingReducer {
    
    private func updateResult(
        _ result: (Result<Landing, LoadFailure>),
        _ state: inout OrderCardLandingDomain.LandingState<Landing>
    ) {
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
    
    private func dismissInformer(
        _ state: inout OrderCardLandingDomain.LandingState<Landing>
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
