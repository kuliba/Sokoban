//
//  SelectorReducer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

final class SelectorReducer<T: Equatable> {}

extension SelectorReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case .toggleOptions:
            state.isShowingOptions.toggle()
            
        case let .selectOption(option):
            if state.options.contains(option) {
                
                state.selected = option
                state.isShowingOptions = false
            }
            
        case let .setSearchQuery(query):
            state.searchQuery = query
        }
        
        return (state, nil)
    }
}

extension SelectorReducer {
    
    typealias State = Selector<T>
    typealias Event = SelectorEvent<T>
    typealias Effect = Never
}
