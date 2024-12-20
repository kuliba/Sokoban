//
//  FilterableItem.swift
//  
//
//  Created by Igor Malyarov on 07.12.2024.
//

/// `FilterableItem` represents an item that can be filtered by a given query.
/// The `matches(_:)` method determines if the item should be included based on query criteria.
public protocol FilterableItem<Query>: Identifiable {
    
    associatedtype Query: PageQuery where ID == Query.ID
    
    func matches(_ query: Query) -> Bool
}
