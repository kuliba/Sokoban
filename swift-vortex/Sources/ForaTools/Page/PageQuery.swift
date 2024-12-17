//
//  PageQuery.swift
//  
//
//  Created by Igor Malyarov on 07.12.2024.
//

/// `PageQuery` defines the criteria for retrieving a page of items.
/// It includes an optional `id` from which to start the page and a `pageSize`.
public protocol PageQuery<ID> {
    
    associatedtype ID: Hashable
    
    var id: ID? { get }
    var pageSize: Int { get }
}
