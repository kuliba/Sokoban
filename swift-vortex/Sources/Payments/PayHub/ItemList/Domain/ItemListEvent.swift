//
//  ItemListEvent.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

public enum ItemListEvent<Entity>
where Entity: Identifiable {
    
    case load
    case loaded([Element]?)
    case reload
    case update(state: LoadState, forID: Entity.ID)
    
    public typealias Element = Stateful<Entity, LoadState>
}

extension ItemListEvent: Equatable where Entity: Equatable {}
