//
//  SerialStampedCachingDecorator.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

/// A decorator class that adds caching functionality to a `Decoratee`.
/// It stores the fetched data in a cache **only when the decoratee succeeds**.
public final class SerialStampedCachingDecorator<Payload, Serial, Value>
where Serial: Equatable {
    
    /// The function being decorated (i.e., the original function whose result may be cached).
    private let decoratee: Decoratee
        
    /// The caching mechanism that will store the response.
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
    
    /// The completion handler type for the decorated function.
    ///
    /// - Parameter result: A `Result` containing either a `SerialStamped<Serial, Value>` on success or an `Error` on failure.
    typealias DecorateeCompletion = (Result<SerialStamped<Serial, Value>, Error>) -> Void
    
    /// The original decoratee function that takes a `Payload` and a completion handler.
    /// It may perform some asynchronous work and then call the completion handler.
    typealias Decoratee = (Payload, @escaping DecorateeCompletion) -> Void
    
    /// The completion handler type for caching operations.
    typealias CacheCompletion = () -> Void
    
    /// The cache function that stores a `SerialStamped<Serial, Value>` and calls a completion handler.
    typealias Cache = (SerialStamped<Serial, Value>, @escaping CacheCompletion) -> Void
}

public extension SerialStampedCachingDecorator {
    
    /// Allows the instance to be called as a function, applying the decorated behaviour.
    ///
    /// - Parameters:
    ///   - payload: A `Payload` to provide to the decoratee.
    ///   - completion: A completion handler that returns the result of the decorated function.
    func callAsFunction(
        _ payload: Payload,
        completion: @escaping DecorateeCompletion
    ) {
        decorated(payload, completion: completion)
    }
}

public extension SerialStampedCachingDecorator {
    
    /// The main decorated function that applies caching logic to the original decoratee.
    ///
    /// - Parameters:
    ///   - payload: A `Payload` to provide to the decoratee.
    ///   - completion: A completion handler that returns the result of the decorated function.
    ///
    /// This function invokes the decoratee to fetch the result. If the decoratee **succeeds**, it caches the result,
    /// and then calls the completion handler with the success result. If the decoratee fails, it simply calls
    /// the completion handler with the failure.
    func decorated(
        _ payload: Payload,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(payload) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .failure(failure):
                // On failure, simply pass the error to the completion handler.
                completion(.failure(failure))
                
            case let .success(success):
                // On success, cache the result and then call the completion handler.
                self.cache(success) { completion(.success(success)) }
            }
        }
    }
}
