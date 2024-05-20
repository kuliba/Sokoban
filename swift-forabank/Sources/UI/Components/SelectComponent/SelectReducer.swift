//
//  SelectReducer.swift
//  
//
//  Created by Дмитрий Савушкин on 25.04.2024.
//

import Foundation

final class SelectReducer<Icon> {}

extension SelectReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        switch event {
        case let .chevronTapped(options: options, selectOption: option):
            if case .collapsed = state {
                return .init(state: .expanded(
                    selectOption: option,
                    options: options ?? [],
                    searchText: state.searchText
                ))
            } else {
                
                return .collapsed(option: option, options: options)
            }
        case let .optionTapped(option):
            return .collapsed(option: option, options: nil)
            
        case let .search(text):
            return .expanded(
                selectOption: nil,
                options: (state.filteredOption ?? state.options) ?? [],
                searchText: text
            )
        }
    }
}

extension SelectState {

    var filteredOption: [SelectState.Option]? {
    
        if let searchText {
            return self.options?
                .filter({$0.title.localizedCaseInsensitiveContains(searchText)})
        } else {
            return self.options
        }
    }
    
    var options: [SelectState.Option]? {
    
        if case let .expanded(_, options, _) = self {
            return options
        } else {
            return nil
        }
    }
    
    var searchText: String? {
        
        if case let .expanded(_, _, searchText) = self {
            return searchText
        } else {
            return nil
        }
    }
}

extension SelectReducer {
    
    typealias State = SelectState
    typealias Event = SelectEvent
}
