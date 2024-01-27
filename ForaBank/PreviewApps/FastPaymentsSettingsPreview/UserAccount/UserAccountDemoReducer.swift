//
//  UserAccountDemoReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 27.01.2024.
//

import FastPaymentsSettings

final class UserAccountDemoReducer {}

extension UserAccountDemoReducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ informer: @escaping (String) -> Void
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
                informer("Demo informer here.")
                
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
    
    typealias State = UserAccountViewModel.State
    typealias Event = UserAccountViewModel.Event.Demo
    typealias Effect = UserAccountViewModel.Effect.Demo
}
