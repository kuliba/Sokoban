//
//  AnyOptionalFetcher.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// A type-erased optional fetcher that can fetch a `T?` value for a given `Payload`.
public struct AnyOptionalFetcher<Payload, T> {
    
    private let _fetch: Fetch
    
    /// Creates a type-erased optional fetcher from a given fetch closure.
    ///
    /// - Parameter fetch: A closure that fetches an optional `T` for the given `Payload`.
    public init(fetch: @escaping Fetch) {
        
        self._fetch = fetch
    }
    
    /// A closure type that takes a `Payload` and a completion handler, fetching an optional `T` asynchronously.
    public typealias Fetch = (Payload, @escaping (T?) -> Void) -> Void
}

extension AnyOptionalFetcher: OptionalFetcher {
    
    /// Fetches an optional `T` for the given `Payload`, calling the completion handler when done.
    public func fetch(
        _ payload: Payload,
        completion: @escaping (T?) -> Void
    ) {
        _fetch(payload, completion)
    }
}

/// Extends `AnyOptionalFetcher` for cases where no payload is required.
///
/// When `Payload` is `Void`, this extension provides a simplified initializer and a `fetch` method that omit the payload parameter.
public extension AnyOptionalFetcher where Payload == Void {
    
    /// Initializes an `AnyOptionalFetcher` without requiring a payload.
    ///
    /// - Parameter fetch: A closure that fetches a `T?` value asynchronously.
    init(
        fetch: @escaping (@escaping (T?) -> Void) -> Void
    ) {
        self.init { _, completion in fetch(completion) }
    }
    
    /// Fetches data without requiring a payload.
    ///
    /// - Parameter completion: A closure called with the fetched `T` value, or `nil` if the fetch fails.
    func fetch(
        completion: @escaping (T?) -> Void
    ) {
        fetch((), completion: completion)
    }
}
