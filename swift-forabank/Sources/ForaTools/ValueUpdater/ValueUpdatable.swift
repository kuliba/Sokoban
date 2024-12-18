//
//  ValueUpdatable.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

/// A protocol that defines how to read and create updated instances of a value type.
/// Conforming types must specify a `Value` type, provide a `KeyPath` to read the value,
/// and a method to produce a new instance with an updated value.
public protocol ValueUpdatable<Value> {
    
    associatedtype Value
    
    /// A key path pointing to the `Value` property within the conforming type.
    var keyPath: KeyPath<Self, Value> { get }
    
    /// Returns a new instance by updating the `Value` of this instance.
    func updated(value: Value) -> Self
}
