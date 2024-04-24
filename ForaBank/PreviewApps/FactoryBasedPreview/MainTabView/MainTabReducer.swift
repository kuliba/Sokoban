//
//  MainTabReducer.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

final class MainTabReducer {}

extension MainTabReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case let .switchTo(state):
            return (state, nil)
        }
    }
}

extension MainTabReducer {
    
    typealias State = MainTabState
    typealias Event = MainTabEvent
    typealias Effect = MainTabEffect
}
