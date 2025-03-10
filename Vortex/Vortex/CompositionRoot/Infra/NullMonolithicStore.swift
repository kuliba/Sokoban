//
//  NullMonolithicStore.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.03.2025.
//

import SerialComponents

/// A no-op implementation of `MonolithicStore` that always fails on insertion and returns `nil` on retrieval.
/// This can be used as a placeholder or a default implementation when no actual storage is needed.
final class NullMonolithicStore<T> {}

extension NullMonolithicStore: MonolithicStore {
    
    /// Attempts to insert an item but always fails with `InsertFailure`.
    /// - Parameters:
    ///   - _: The item to insert (ignored).
    ///   - completion: A completion handler returning a failure result.
    func insert(
        _: T,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completion(.failure(InsertFailure()))
    }
    
    /// Attempts to retrieve an item but always returns `nil`.
    /// - Parameter completion: A completion handler returning `nil`.
    func retrieve(
        _ completion: @escaping (Value?) -> Void
    ) {
        completion(nil)
    }
    
    /// Represents an insertion failure error.
    struct InsertFailure: Error {}
}
