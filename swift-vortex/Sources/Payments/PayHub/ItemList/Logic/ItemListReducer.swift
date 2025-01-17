//
//  ItemListReducer.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

public final class ItemListReducer<ID, Entity>
where ID: Hashable,
      Entity: Identifiable {
    
    @usableFromInline
    let makeID: MakeID
    
    @usableFromInline
    let makePlaceholders: MakePlaceholders
    
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

public extension ItemListReducer {
    
    typealias State = ItemListState<ID, Entity>
    typealias Event = ItemListEvent<Entity>
    typealias Effect = ItemListEffect
    
    @inlinable
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .load:
            load(&state, &effect)
            
        case .reload:
            reload(&state, &effect)
            
        case let .loaded(elements):
            handleLoaded(&state, &effect, with: elements)
            
        case let .update(state: loadState, forID: id):
            state.setSuffix(to: state.suffix.map {
                
                guard case let .element(identified) = $0,
                      identified.element.id == id
                else { return $0 }
                
                return .element(.init(id: identified.id, element: .init(entity: identified.element.entity, state: loadState)))
            })
        }
        
        return (state, effect)
    }
}

extension ItemListReducer {
    
    @usableFromInline
    func load(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.setSuffix(to: makePlaceholders().map { .placeholder($0) })
        effect = .load
    }
    
    @usableFromInline
    typealias Element = Stateful<Entity, LoadState>
    
    @usableFromInline
    func handleLoaded(
        _ state: inout State,
        _ effect: inout Effect?,
        with elements: [Element]?
    ) {
        guard let elements else {
            
            return state.setSuffix(to: [])
        }
        
        state.setSuffix(
            to: state.suffix
                .map(\.id)
                .assignIDs(elements, makeID)
                .map { .element($0) }
        )
    }
    
    @usableFromInline
    func reload(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        state.setSuffix(to: makePlaceholders().map { .placeholder($0) })
        effect = .reload
    }
}

private extension Array where Element: Identifiable {
    
    func updating(
        withID id: Element.ID,
        update: (Element) -> Element
    ) -> Self {
        
        map { $0.id == id ? update($0) : $0 }
    }
}
