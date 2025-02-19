//
//  FormContentReducer.swift
//  
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation

public final class FormContentReducer<Landing, InformerPayload> {
    
    public init(){}
}

public extension FormContentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            if !state.status.isLoading {
                let oldLanding = state.status.oldLanding
                state.status = .inflight(oldLanding)
                effect = .load
            }
            
        case let .loaded(landing):
            state.status = .loaded(landing)
            
        case let .failure(failure):
            switch failure.kind {
            case let .alert(message):
                let oldLanding = state.status.oldLanding
                state.status = .failure(.alert(message), oldLanding)
                
            case let .informer(informer):
                let oldLanding = state.status.oldLanding
                state.status = .failure(.informer(informer), oldLanding)
            }
                        
        case .offset:
            break
            
        case let .dismissInformer(oldLanding):
            state.status = .loaded(oldLanding)
            
        case .getVerificationCode:
            effect = .getVerificationCode
            
        case let .verificationCode(code):
            break
        }
        return (state, effect)
    }
}

public extension FormContentReducer {
    
    typealias State = SavingsAccountContentState<Landing, InformerPayload>
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
}
