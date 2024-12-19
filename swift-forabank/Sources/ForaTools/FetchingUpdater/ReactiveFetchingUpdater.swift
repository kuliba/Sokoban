//
//  ReactiveFetchingUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

/// A reactive utility that fetches a value of type `T` from a `Payload` and updates it to produce one or more `V` values.
///
/// Use `load(payload:completion:)` to start the process. If fetching succeeds, it transforms the fetched `T` into an `AnyPublisher<V, Never>`,
/// allowing multiple `V` values to be emitted over time. If fetching fails or the process completes without emission, `completion` is called with `nil`.
public final class ReactiveFetchingUpdater<Payload, T, V> {
    
    /// A closure that attempts to fetch a `T` from a given `Payload`, delivering `nil` upon failure.
    private let fetch: Fetch
    
    /// A closure that transforms a fetched `T` into an `AnyPublisher<V, Never>`, producing zero or more `V` values.
    private let update: Update
    
    private var cancellable: AnyCancellable?
    
    /// Creates an instance of `ReactiveFetchingUpdater`.
    ///
    /// - Parameters:
    ///   - fetch: A closure that fetches `T?` from `Payload`.
    ///   - update: A closure that converts `T` into a stream of `V` values.
    public init(
        fetch: @escaping Fetch,
        update: @escaping Update
    ) {
        self.fetch = fetch
        self.update = update
    }
    
    /// A closure type that takes a `Payload` and a completion closure. The completion closure receives an optional `T`.
    public typealias Fetch = (Payload, @escaping (T?) -> Void) -> Void
    
    /// A closure type that takes a `T` and returns an `AnyPublisher<V, Never>`.
    public typealias Update = (T) -> AnyPublisher<V, Never>
}

public extension ReactiveFetchingUpdater {
    
    /// Initiates the fetch-and-update process.
    ///
    /// - Parameters:
    ///   - payload: The input needed to fetch a `T`.
    ///   - completion: A closure called with a `V?` value. If the fetch fails or the pipeline completes
    ///     without emitting any `V`, this closure is called with `nil`. Each emitted `V` value from the update pipeline
    ///     is also delivered to this completion closure.
    func load(
        payload: Payload,
        completion: @escaping (V?) -> Void
    ) {
        cancellable = Future { [weak self] promise in
            
            guard let self else { return promise(.success(nil)) }
            
            fetch(payload) { promise(.success($0)) }
        }
        .compactMap { $0 }
        .flatMap(update)
        .sink(
            receiveCompletion: { _ in completion(nil) },
            receiveValue: completion
        )
    }
}
