//
//  MonolithicStore.swift
//
//
//  Created by Igor Malyarov on 15.10.2024.
//

/// A protocol representing a monolithic store for a specific type of value.
public protocol MonolithicStore<Value> {
    
    associatedtype Value
    
    /// Completion handler for insert operations.
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    /// Completion handler for retrieve operations.
    typealias RetrieveCompletion = (Value?) -> Void
    
    /// Inserts a value into the store.
    /// - Parameters:
    ///   - value: The value to insert.
    ///   - completion: A closure called upon completion of the insert operation.
    func insert(_: Value, _: @escaping InsertCompletion)
    /// Retrieves the stored value.
    /// - Parameter completion: A closure called with the retrieved value.
    func retrieve(_: @escaping RetrieveCompletion)
}
