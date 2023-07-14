//
//  ItemSelectModel.swift
//  
//
//  Created by Igor Malyarov on 03.06.2023.
//

import Combine

/// ## State
/// // "expanded" means "showing item list"
/// - collapsed, not editing
/// - expanded, editing
/// - selected(Item, expanded/collapsed)
///
/// ## Sources of Actions (events)
/// - Text field state change // subscribe to publisher, pipeline
/// - Chevron toggle // action
/// - Item list item selection // action
///
/// ## Actions
/// - filterList(String)
/// - select(Item)
/// - toggleListVisibility(Bool)

final class ItemSelectModel<Item>: ObservableObject
where Item: Equatable {
    
    @Published private(set) var state: State
    
    private let items: [Item]
    private let filterKeyPath: KeyPath<Item, String>
    let textField: any TextField<Item>
    private let stateSubject = PassthroughSubject<State, Never>()
    
    init(
        initialState: State,
        items: [Item],
        filterKeyPath: KeyPath<Item, String>,
        textField: any TextField<Item>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.items = items
        self.filterKeyPath = filterKeyPath
        self.textField = textField
        
        textField
            .itemSelectStatePublisher(items, filterKeyPath: filterKeyPath)
            .merge(with: stateSubject)
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    func send(_ action: Action) {
        
        guard let (state, sideEffect) = try? Self.reduce(state, with: action, items: items, filterKeyPath: filterKeyPath)
        else { return } // TODO: log error
        
        stateSubject.send(state)
        sideEffect.map(textField.send(_:))
    }
    
    enum State: Equatable {
        
        case collapsed
        case expanded([Item])
        case selected(Item, listState: ListState)
        
        enum ListState: Equatable {
            
            case collapsed
            case expanded
        }
    }
    
    enum Action: Equatable {
        
        case filterList(String?)
        case select(Item)
        case toggleListVisibility
    }
    
    typealias SideEffect = TextFieldAction<Item>
    
    static func reduce(
        _ state: State,
        with action: Action,
        items: [Item],
        filterKeyPath: KeyPath<Item, String>
    ) throws -> (State, SideEffect?) {
        
        let newState: State
        var sideEffect: SideEffect?
        
        switch action {
        case let .select(item):
            switch state {
            case .collapsed:
                throw Error.impossibleTransition(from: state, with: action)
                
            case .expanded:
                newState = .selected(item, listState: .collapsed)
                sideEffect = .select(item)
                
            case .selected(_, listState: .collapsed):
                newState = .selected(item, listState: .expanded)
                sideEffect = nil
                
            case .selected(_, listState: .expanded):
                newState = .selected(item, listState: .collapsed)
                sideEffect = .select(item)
            }
            
        case .toggleListVisibility:
            switch state {
            case .collapsed:
                newState = .expanded(items)
                sideEffect = .startEditing
                
            case .expanded:
                newState = .collapsed
                sideEffect = .finishEditing
                
            case let .selected(item, .collapsed):
                newState = .selected(item, listState: .expanded)
                sideEffect = .startEditing
                
            case let .selected(item, .expanded):
                newState = .selected(item, listState: .collapsed)
                sideEffect = .finishEditing
            }
            
        case let .filterList(text):
            switch state {
            case .collapsed, .selected:
                throw Error.impossibleTransition(from: state, with: action)
                
            case .expanded:
                newState = .expanded(items.filtered(with: text, keyPath: filterKeyPath))
            }
        }
        
        return (newState, sideEffect)
    }
    
    enum Error: Swift.Error {
        
        case impossibleTransition(from: State, with: Action)
    }
}
