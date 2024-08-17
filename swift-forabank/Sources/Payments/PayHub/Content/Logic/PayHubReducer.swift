//
//  PayHubReducer.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Foundation

public final class PayHubReducer<Element> {
    
    private let makePlaceholders: MakePlaceholders
    
    public init(
        makePlaceholders: @escaping MakePlaceholders
    ) {
        self.makePlaceholders = makePlaceholders
    }
    
    public typealias MakePlaceholders = () -> [UUID]
}

public extension PayHubReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
            
        case let .loaded(elements):
            handleLoaded(&state, &effect, with: elements)
            
        case let .select(item):
            state.selected = item
        }
        
        return (state, effect)
    }
}

public extension PayHubReducer {
    
    typealias State = PayHubState<Element>
    typealias Event = PayHubEvent<Element>
    typealias Effect = PayHubEffect
}

private extension PayHubReducer {
    
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.loadState = .placeholders(makePlaceholders())
        state.selected = nil
        effect = .load
    }
    
    func handleLoaded(
        _ state: inout State,
        _ effect: inout Effect?,
        with elements: [Element]
    ) {
        switch state.loadState {
        case .loaded:
            break
            
        case let .placeholders(ids):
            state.loadState = .loaded(ids.assignIDs(elements, UUID.init))
        }
    }
}
