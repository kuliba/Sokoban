//
//  KeyProviding.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

/// A type that provides a unique key identifying each instance.
///
/// Conform to `KeyProviding` to let clients distinguish or update specific items in a collection.
public protocol KeyProviding<Key> {
    
    associatedtype Key: Hashable
    
    /// A unique key identifying this instance.
    var key: Key { get }
}
