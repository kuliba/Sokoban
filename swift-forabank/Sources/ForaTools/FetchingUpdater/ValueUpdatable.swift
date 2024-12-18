//
//  ValueUpdatable.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

/// A type that can produce a new instance by applying a new value.
///
/// Conform to `ValueUpdatable` to allow instances to be easily updated with new values, often as part of a reactive update process.
public protocol ValueUpdatable<Value> {
    
    associatedtype Value
        
    /// Returns a new instance by updating the `Value` of this instance.
    ///
    /// Use this method to create a modified copy of the original element with the given new value.
    func updated(value: Value) -> Self
}
