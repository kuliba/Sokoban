//
//  FetchingUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

/// A utility that orchestrates fetching a value and then updating it to produce a new result.
///
/// `FetchingUpdater` first fetches a value of type `T` given an input `Payload`. If a value is
/// successfully fetched, it then applies an update operation to produce one or more values of type `V`.
/// If fetching fails (returns `nil`), the completion handler is invoked with `nil`.
public final class FetchingUpdater<Payload, T, V> {
    
    private let fetch: Fetch
    private let update: Update
    
    /// Creates a `FetchingUpdater` with the given fetch and update closures.
    ///
    /// - Parameters:
    ///   - fetch: A closure that attempts to fetch a `T` from a given `Payload`.
    ///   - update: A closure that updates a `T` into one or more `V` values.
    public init(
        fetch: @escaping Fetch,
        update: @escaping Update
    ) {
        self.fetch = fetch
        self.update = update
    }
    
    /// A closure type that takes a `Payload` and a completion closure. The completion closure receives an optional `T`.
    public typealias Fetch = (Payload, @escaping (T?) -> Void) -> Void
    
    /// A closure type that takes a `T` and a completion closure. The completion closure receives a `V` value.
    public typealias Update = (T, @escaping (V) -> Void) -> Void
}

public extension FetchingUpdater {
    
    /// Initiates the fetch-and-update process.
    ///
    /// - Parameters:
    ///   - payload: The input needed to fetch a `T`.
    ///   - completion: A closure invoked with a `V?` result:
    ///     - `V` if the update operation produces a value.
    ///     - `nil` if the fetch fails or no value is produced.
    ///
    /// The completion closure may be called multiple times if the update operation produces multiple values.
    func load(
        payload: Payload,
        completion: @escaping (V?) -> Void
    ) {
        fetch(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .none:
                completion(nil)
                
            case let .some(value):
                update(value, completion)
            }
        }
    }
}
