//
//  SelectReducer.swift
//  
//
//  Created by Дмитрий Савушкин on 25.04.2024.
//

import Foundation

public final class SelectReducer {
    
    public init() {}
}

extension SelectReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case let .chevronTapped(options: options, selectOption: option):
            if case .collapsed = state.state {
                return (.init(image: state.image, state: .expanded(
                    selectOption: option,
                    options: options ?? [],
                    searchText: state.state.searchText
                )), nil)
            } else {
                
                return (.init(image: state.image, state: .collapsed(option: option, options: options)), nil)

            }
        case let .optionTapped(option):
            return (.init(image: state.image, state: .collapsed(option: option, options: nil)), nil)
            
        case let .search(text):
            return (.init(image: state.image, state: .expanded(
                selectOption: nil,
                options: (state.state.filteredOption ?? state.state.options) ?? [],
                searchText: text
            )), nil)
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
    
    typealias State = SelectUIState
    typealias Event = SelectEvent
    typealias Effect = Never
}
