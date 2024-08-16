//
//  TabReducer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

final class TabReducer {}

extension TabReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .switchTo(tab):
            state = tab
        }
        
        return (state, effect)
    }
}

extension TabReducer {
    
    typealias State = TabState
    typealias Event = TabEvent
    typealias Effect = TabEffect
}
