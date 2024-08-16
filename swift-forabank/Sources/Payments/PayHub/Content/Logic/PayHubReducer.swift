//
//  PayHubReducer.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public final class PayHubReducer<Latest> {
    
    public init() {}
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
            state = .none
            effect = .load
            
        case let .loaded(loaded):
            state = .init(items: [.templates, .exchange] + loaded.map { .latest($0) })
            
        case let .select(item):
            state?.selected = item
        }
        
        return (state, effect)
    }
}

public extension PayHubReducer {
    
    typealias State = PayHubState<Latest>
    typealias Event = PayHubEvent<Latest>
    typealias Effect = PayHubEffect
}
