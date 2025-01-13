//
//  OptionalFetcher.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

/// A protocol for types that can fetch an optional `T` using a given `Payload`.
public protocol OptionalFetcher<Payload, T> {
    
    associatedtype Payload
    associatedtype T
    
    /// Fetches an optional `T` for the given `Payload`, calling the completion handler when done.
    func fetch(
        _ payload: Payload,
        completion: @escaping (T?) -> Void
    )
}
