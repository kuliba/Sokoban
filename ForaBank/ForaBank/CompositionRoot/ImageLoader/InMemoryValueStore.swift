//
//  InMemoryValueStore.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.06.2024.
//

import Foundation

// TODO: move to infra

/// A thread-safe in-memory store for caching values.
final class InMemoryValueStore<Key, Value>
where Key: Hashable {
    
    private var storage: [Key: Value]
    private let lock = NSRecursiveLock()
    
    /// Initialises the `InMemoryValueStore` with an optional initial storage.
    ///
    /// - Parameter storage: A dictionary containing the initial set of values. Defaults to an empty dictionary.
    init(
        storage: [Key: Value] = [:]
    ) {
        self.storage = storage
    }
}

extension InMemoryValueStore {
    
    /// Retrieves an value for the given key asynchronously.
    ///
    /// - Parameters:
    ///   - key: The key to retrieve the value.
    ///   - completion: The completion handler to call with the result.
    func retrieve(
        key: Key,
        _ completion: @escaping (Result<Value, Error>) -> Void
    ) {
        completion(retrieve(key))
    }
    
    /// Retrieves values for the given keys asynchronously.
    ///
    /// - Parameters:
    ///   - keys: The keys to retrieve the values.
    ///   - completion: The completion handler to call with the results.
    func retrieve(
        keys: [Key],
        _ completion: @escaping ([Result<Value, Error>]) -> Void
    ) {
        completion(keys.map(retrieve(_:)))
    }
    
    /// Retrieves a value for the given key.
    ///
    /// - Parameter key: The key to retrieve the value.
    /// - Returns: A result containing the value or an error if the key is not found.
    private func retrieve(
        _ key: Key
    ) -> Result<Value, Error> {
        
        if let value = storage[key] {
            .success(value)
        } else {
            .failure(RetrievalFailure())
        }
    }
    
    struct RetrievalFailure: Error {}
}

extension InMemoryValueStore {
    
    /// Saves an value for the given key asynchronously.
    ///
    /// - Parameters:
    ///   - payload: A tuple containing the key and the value to be saved.
    ///   - completion: The completion handler to call with the result.
    func save(
        payload: (key: Key, value: Value),
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        storage[payload.key] = payload.value
        completion(.success(()))
    }
    
    /// Saves multiple values for the given keys asynchronously.
    ///
    /// - Parameters:
    ///   - payloads: An array of tuples containing the keys and the values to be saved.
    ///   - completion: The completion handler to call with the result.
    func save(
        payloads: [(key: Key, value: Value)],
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        storage.merge(payloads) { _, last in last }
        completion(.success(()))
    }
    
    struct SaveFailure: Error {}
}
