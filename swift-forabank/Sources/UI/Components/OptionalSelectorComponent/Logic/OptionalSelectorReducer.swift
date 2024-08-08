//
//  OptionalSelectorReducer.swift
//
//
//  Created by Igor Malyarov on 08.08.2024.
//

public final class OptionalSelectorReducer<Item> {
    
    private let predicate: SearchPredicate
    
    public init(predicate: @escaping SearchPredicate) {
        
        self.predicate = predicate
    }
}

public extension OptionalSelectorReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .search(query):
            state.searchQuery = query
            if query.isEmpty {
                state.filteredItems = state.items
            } else {
                state.filteredItems = state.items.filter {
                    predicate($0, query)
                }
            }
            
        case let .select(item):
            state.selected = item
            state.isShowingItems = false
            
        case .toggleOptions:
            state.isShowingItems.toggle()
        }
        
        return (state, effect)
    }
}

public extension OptionalSelectorReducer {
    
    typealias SearchPredicate = (Item, String) -> Bool
    
    typealias State = OptionalSelectorState<Item>
    typealias Event = OptionalSelectorEvent<Item>
    typealias Effect = OptionalSelectorEffect
}
