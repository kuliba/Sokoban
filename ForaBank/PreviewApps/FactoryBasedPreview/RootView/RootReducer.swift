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
            reduce(&state, spinnerEvent)
            
        case let .tab(tabEvent):
            reduce(&state, tabEvent)
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
        _ state: inout State,
        _ event: SpinnerEvent
    ) {
        switch event {
        case .hide:
            state.spinner = .off
        case .show:
            state.spinner = .on
        }
    }
    
    func reduce(
        _ state: inout State,
        _ event: MainTabEvent
    ) {
        switch event {
        case let .switchTo(tab):
            state.tab = tab
        }
    }
}
