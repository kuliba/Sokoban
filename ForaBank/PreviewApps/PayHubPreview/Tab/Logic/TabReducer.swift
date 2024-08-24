//
//  TabReducer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

final class TabReducer<Content> {}

extension TabReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(tab):
            state.selected = tab
        }
        
        return (state, effect)
    }
}

extension TabReducer {
    
    typealias State = TabState<Content>
    typealias Event = TabEvent<Content>
    typealias Effect = TabEffect
}
