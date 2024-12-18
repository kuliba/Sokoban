//
//  KeyProviding.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

/// A protocol that provides a unique key for an object.
/// Types conforming to this protocol must specify a `Key` type and provide a unique `key`.
public protocol KeyProviding<Key> {
    
    associatedtype Key: Hashable
    
    /// A unique key identifying this instance.
    var key: Key { get }
}
