//
//  CachingDecorator.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

/// A decorator that adds caching behavior to a loading operation.
///
/// Executes a decorated task and caches the result if successful.
/// The completion handler receives the cached response or `nil` if the operation fails.
public final class CachingDecorator<Payload, Response> {
    
    /// The decorated loading operation that fetches data.
    @usableFromInline
    let decoratee: Decoratee
    
    /// The caching operation that stores the response.
    @usableFromInline
    let cache: Cache
    
    /// Initializes the decorator with a loading operation and a caching strategy.
    ///
    /// - Parameters:
    ///   - decoratee: The primary loading function to fetch data.
    ///   - cache: The caching function to store successful responses.
    public init(
        decoratee: @escaping Decoratee,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    /// The completion handler used by both the decoratee and cache.
    ///
    /// Passes the response if successful, or `nil` if the operation fails.
    public typealias Completion = (Response?) -> Void
    
    /// The decorated loading operation that retrieves data.
    ///
    /// - Parameters:
    ///   - payload: The input for the loading operation.
    ///   - completion: Completion handler that receives the result or `nil` on failure.
    public typealias Decoratee = (Payload, @escaping Completion) -> Void
    
    /// The caching operation that stores the response.
    ///
    /// - Parameters:
    ///   - response: The successful response to cache.
    ///   - completion: Completion handler that confirms if caching was successful (`response`) or failed (`nil`).
    public typealias Cache = (Response, @escaping Completion) -> Void
}

public extension CachingDecorator {
    
    /// Loads data using the decorated function and caches the result if successful.
    ///
    /// - Parameters:
    ///   - payload: The input for the loading operation.
    ///   - completion: Completion handler that receives the cached response or `nil` on failure.
    @inlinable
    func load(
        _ payload: Payload,
        completion: @escaping Completion
    ) {
        decoratee(payload) { [weak self] result in
            
            guard let self else { return }
            
            guard let result else { return completion(nil) }
            
            cache(result) { [weak self] in
                
                guard self != nil else { return }
                
                completion($0)
            }
        }
    }
}
