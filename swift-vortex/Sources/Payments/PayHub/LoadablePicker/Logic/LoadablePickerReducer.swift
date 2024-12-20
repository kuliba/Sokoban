//
//  LoadablePickerReducer.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

public final class LoadablePickerReducer<ID, Element>
where ID: Hashable {
    
    private let makeID: MakeID
    private let makePlaceholders: MakePlaceholders
    
    public init(
        makeID: @escaping MakeID,
        makePlaceholders: @escaping MakePlaceholders
    ) {
        self.makeID = makeID
        self.makePlaceholders = makePlaceholders
    }
    
    public typealias MakeID = () -> ID
    public typealias MakePlaceholders = () -> [ID]
}

public extension LoadablePickerReducer {
    
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
            
        case .reload:
            reload(&state, &effect)
            
        case let .select(element):
            state.selected = element
        }
        
        return (state, effect)
    }
}

public extension LoadablePickerReducer {
    
    typealias State = LoadablePickerState<ID, Element>
    typealias Event = LoadablePickerEvent<Element>
    typealias Effect = LoadablePickerEffect
}

private extension LoadablePickerReducer {
    
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.suffix = makePlaceholders().map { .placeholder($0) }
        state.selected = nil
        effect = .load
    }
    
    func handleLoaded(
        _ state: inout State,
        _ effect: inout Effect?,
        with elements: [Element]?
    ) {
        guard let elements else { return }
        
        state.suffix = state.suffix
            .map(\.id)
            .assignIDs(elements, makeID)
            .map { State.Item.element($0) }
    }
    
    func reload(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.suffix = makePlaceholders().map { .placeholder($0) }
        state.selected = nil
        effect = .reload
    }
}
