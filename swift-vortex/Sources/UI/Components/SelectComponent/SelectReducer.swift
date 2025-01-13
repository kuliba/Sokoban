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

public extension SelectReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case let .chevronTapped(options: options, selectOption: option):
            let selectState: SelectState
            switch state.state {
            case .collapsed: selectState = .expanded(
                selectOption: option,
                options: options ?? [],
                searchText: state.state.searchText
            )
            case .expanded: selectState = .collapsed(option: option, options: options)
            }
            return (.init(image: state.image, state: selectState), nil)
            
        case let .optionTapped(option):
            return (.init(image: state.image, state: .collapsed(option: option, options: nil)), nil)
            
        case let .search(text):
            let options = state.state.filteredOption ?? state.state.options ?? []
            return (.init(image: state.image, state: .expanded(selectOption: nil, options: options, searchText: text)), nil)
        }
    }
}

public extension SelectState {

    var filteredOption: [SelectState.Option]? {
        
        if let searchText {
            return self.options?
                .filter({
                    $0.title.localizedCaseInsensitiveContains(searchText)
                })
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

public extension SelectReducer {
    
    typealias State = SelectUIState
    typealias Event = SelectEvent
    typealias Effect = Never
}
