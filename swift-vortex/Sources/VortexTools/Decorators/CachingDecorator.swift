//
//  CachingDecorator.swift
//
//
//  Created by Igor Malyarov on 17.01.2025.
//

/// A decorator that adds caching behavior to a loading operation.
/// - Executes a decorated task and caches the result if successful.
/// - Delivers `true` if caching succeeds, `false` otherwise.
public final class CachingDecorator<Payload, Response> {
    
    @usableFromInline
    let decoratee: Decoratee
    
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
    
    /// The decorated loading operation.
    public typealias Decoratee = (Payload, @escaping (Response?) -> Void) -> Void
    
    /// The caching operation that stores the response.
    public typealias Cache = (Response, @escaping (Bool) -> Void) -> Void
}

public extension CachingDecorator {
    
    /// Loads data using the decorated function and caches the result if successful.
    ///
    /// - Parameters:
    ///   - payload: The input for the loading operation.
    ///   - completion: Completion handler with `true` if caching succeeded, `false` otherwise.
    @inlinable
    func load(
        _ payload: Payload,
        completion: @escaping (Bool) -> Void
    ) {
        decoratee(payload) { [weak self] result in
            
            guard let self else { return }
            
            guard let result else { return completion(false) }
            
            cache(result) { [weak self] in
                
                guard self != nil else { return }
                
                completion($0)
            }
        }
    }
}
