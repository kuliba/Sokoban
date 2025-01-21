//
//  ItemListState.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

public struct ItemListState<ID, Entity>
where ID: Hashable {
    
    private var state: LoadableState
    
    public init(
        prefix: [Item],
        suffix: [Item]
    ) {
        self.state = .init(prefix: prefix, suffix: suffix)
    }
    
    public typealias LoadableState = LoadablePickerState<ID, Stateful<Entity, LoadState>>
    public typealias Item = LoadableState.Item
}

extension ItemListState {
    
    @usableFromInline
    var suffix: [Item] { state.suffix }
    
    @usableFromInline
    mutating func setSuffix(to suffix: [Item]) {
        
        self.state.suffix = suffix
    }
}

extension ItemListState: Equatable where Entity: Equatable {}

public extension ItemListState {
    
    var isLoading: Bool { state.isLoading }
    var items: [Item] { state.items }
    var placeholderIDs: [ID] { state.placeholderIDs }
}

public struct Stateful<Entity, State> {
    
    public let entity: Entity
    public let state: State
    
    public init(
        entity: Entity,
        state: State
    ) {
        self.entity = entity
        self.state = state
    }
}

extension Stateful: Equatable where Entity: Equatable, State: Equatable {}

extension Stateful: Identifiable where Entity: Identifiable {
    
    public var id: Entity.ID { entity.id }
}
