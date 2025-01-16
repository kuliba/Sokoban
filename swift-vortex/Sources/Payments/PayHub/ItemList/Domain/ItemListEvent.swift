//
//  ItemListEvent.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

public enum ItemListEvent<Entity> {
    
    case load
    case loaded([Element]?)
    case reload
    
    public typealias Element = Stateful<Entity, LoadState>
}

extension ItemListEvent: Equatable where Entity: Equatable {}
