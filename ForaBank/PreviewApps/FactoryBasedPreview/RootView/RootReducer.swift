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
        
        switch event {
        case .hide:
            return (.off, nil)
        case .show:
            return (.on, nil)
        }
    }
}

extension RootReducer {
    
    typealias State = SpinnerState
    typealias Event = SpinnerEvent
    typealias Effect = Never
}
