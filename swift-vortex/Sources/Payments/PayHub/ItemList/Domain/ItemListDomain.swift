//
//  ItemListDomain.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

/// A namespace
public enum ItemListDomain<ID, Entity>{}

public extension ItemListDomain
where ID: Hashable,
      Entity: Identifiable {
    
    // Domain
    typealias State = ItemListState<ID, Entity>
    typealias Event = ItemListEvent<Entity>
    typealias Effect = ItemListEffect
    
    // Logic
    typealias Reducer = ItemListReducer<ID, Entity>
    typealias EffectHandler = ItemListEffectHandler<Entity>
}
