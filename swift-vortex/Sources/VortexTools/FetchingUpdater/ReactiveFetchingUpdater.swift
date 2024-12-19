//
//  ReactiveFetchingUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// A reactive component that fetches an initial value of type `T` from a `Payload`, and then updates it to produce `V` values over time.
public final class ReactiveFetchingUpdater<Payload, T, V> {
    
    private let fetcher: any Fetcher
    private let updater: any Updater
    
    private var cancellable: AnyCancellable?
    
    /// Creates a reactive fetching updater with a given fetcher and updater.
    ///
    /// - Parameters:
    ///   - fetcher: An object that fetches an optional `T`.
    ///   - updater: An object that produces a stream of `V` values from a `T`.
    public init(
        fetcher: any Fetcher,
        updater: any Updater
    ) {
        self.fetcher = fetcher
        self.updater = updater
    }
    
    /// A type that can fetch an optional `T` from a `Payload`.
    public typealias Fetcher = OptionalFetcher<Payload, T>
    
    /// A type that can transform a `T` into a publisher of `V` values.
    public typealias Updater = ReactiveUpdater<T, V>
}

public extension ReactiveFetchingUpdater {
    
    /// Loads data from the fetcher using the given `payload` and then applies the updater, calling `completion` with each emitted `V` value.
    ///
    /// If fetching fails or the updater completes without values, `completion(nil)` is called.
    ///
    /// - Parameters:
    ///   - payload: The input used to fetch `T`.
    ///   - completion: Called with each `V` emitted, and `nil` when done or on failure.
    func load(
        payload: Payload,
        completion: @escaping (V?) -> Void
    ) {
        fetcher.fetch(payload) { [weak self] value in
            
            guard let self else { return }
            
            guard let value else { return completion(nil) }
            
            cancellable = updater.update(value)
                .sink(receiveValue: completion)
        }
    }
}

/// Extends `ReactiveFetchingUpdater` for cases where no payload is required.
///
/// When `Payload` is `Void`, this extension provides a simplified `load` method that omits the payload parameter.
public extension ReactiveFetchingUpdater where Payload == Void {
    
    /// Loads data without requiring a payload.
    ///
    /// - Parameter completion: A closure called with each emitted `V` value, and with `nil` when the loading completes or fails.
    func load(
        completion: @escaping (V?) -> Void
    ) {
        load(payload: (), completion: completion)
    }
}
