//
//  UserAccountDemoReducer.swift
//  
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings

final class UserAccountDemoReducer {}

extension UserAccountDemoReducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ inform: @escaping Inform
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .loaded(loaded):
            state.isLoading = false
            
            switch loaded {
            case .alert:
                state.alert = .alert(.error(
                    message: "This is an error alert with a message.",
                    event: .closeAlert
                ))
                
            case .informer:
                inform("Demo informer here.")
                
            case .loader:
                break
            }
            
        case let .show(show):
            state.isLoading = true
            
            switch show {
            case .alert:
                effect = .loadAlert
                
            case .informer:
                effect = .loadInformer
                
            case .loader:
                effect = .loader
            }
        }
        
        return (state, effect)
    }
}

extension UserAccountDemoReducer {
    
    typealias Inform = (String) -> Void
    
    typealias State = UserAccountViewModel.State
    typealias Event = UserAccountNavigation.Event.Demo
    typealias Effect = UserAccountNavigation.Effect.Demo
}
