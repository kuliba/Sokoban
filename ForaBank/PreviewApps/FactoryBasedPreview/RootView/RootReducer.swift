//
//  RootReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class RootReducer {}

extension RootReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .spinner(spinnerEvent):
            (state, _) = reduce(state, spinnerEvent)
        }
        
        return (state, nil)
    }
}

extension RootReducer {
    
    typealias State = RootState
    typealias Event = RootEvent
    typealias Effect = Never
}

private extension RootReducer {
    
    func reduce(
        _ state: State,
        _ event: SpinnerEvent
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .hide:
            state.spinner = .off
        case .show:
            state.spinner = .on
        }
        
        return (state, nil)
    }
}

