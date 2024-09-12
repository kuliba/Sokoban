//
//  SerialStampedCachingDecorator.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

/// A decorator class that adds caching functionality to a `Decoratee` while ensuring
/// that data is stored in a cache only when the serial of the fetched response is different from the provided serial.
public final class SerialStampedCachingDecorator<Response> {
    
    /// The function being decorated (i.e., the original function whose result may be cached).
    private let decoratee: Decoratee
    
    /// The caching mechanism that will store the response if it has a different serial.
    private let cache: Cache
    
    /// Initialises a new `SerialStampedCachingDecorator` with a decoratee and a cache.
    ///
    /// - Parameters:
    ///   - decoratee: The original function whose results may be cached.
    ///   - cache: The cache that will store the decorated results.
    public init(
        decoratee: @escaping Decoratee,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

public extension SerialStampedCachingDecorator {
    
    /// A string that represents the serial associated with a cached or fetched response.
    typealias Serial = String
    
    /// The completion handler type for the decorated function.
    /// - Result can either be a `SerialStamped<String, Response>` on success, or an error on failure.
    typealias DecorateeCompletion = (Result<SerialStamped<String, Response>, Error>) -> Void
    
    /// The original decoratee function that takes an optional `Serial` and a completion handler.
    /// It may perform some asynchronous work and then call the completion handler.
    typealias Decoratee = (Serial?, @escaping DecorateeCompletion) -> Void
    
    /// The completion handler type for caching operations.
    /// - Result is `Void` on success, or an error on failure.
    typealias CacheCompletion = (Result<Void, Error>) -> Void
    
    /// The cache function that stores a `SerialStamped<String, Response>` and calls a completion handler.
    typealias Cache = (SerialStamped<String, Response>, @escaping CacheCompletion) -> Void
}

public extension SerialStampedCachingDecorator {
    
    /// Allows the instance to be called as a function, applying the decorated behavior.
    ///
    /// - Parameters:
    ///   - serial: An optional serial to compare against the response's serial.
    ///   - completion: A completion handler that returns the result of the decorated function.
    ///
    /// This method will fetch a response using the decoratee, and if the response's serial
    /// is different from the provided serial, it will be cached.
    func callAsFunction(
        _ serial: Serial?,
        completion: @escaping DecorateeCompletion
    ) {
        decorated(serial, completion: completion)
    }
}

public extension SerialStampedCachingDecorator {
    
    /// The main decorated function that applies caching logic to the original decoratee.
    ///
    /// - Parameters:
    ///   - serial: An optional serial to compare with the serial of the response.
    ///   - completion: A completion handler that returns the result of the decorated function.
    ///
    /// This function first invokes the decoratee to fetch the result. If the result's serial is
    /// different from the provided serial, it will cache the result and then call the completion handler.
    /// If the serials are the same, it skips caching and simply calls the completion handler.
    func decorated(
        _ serial: Serial?,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(serial) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                // Cache the response only if the serials are different
                if success.serial != serial {
                    self.cache(success) { _ in completion(.success(success)) }
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}
