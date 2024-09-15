//
//  SerialStampedCachingDecorator.swift
//
//
//  Created by Igor Malyarov on 10.09.2024.
//

/// A decorator class that adds caching functionality to a `Decoratee` while ensuring
/// that data is stored in a cache only when the serial of the fetched response is different from the provided serial.
public final class SerialStampedCachingDecorator<Serial, Value>
where Serial: Equatable {
    
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
    
    /// A typealias representing the payload, which is an `AnySerialContainer` encapsulating an optional `Serial`.
    typealias Payload = SerialPayload<Serial?>
    
    /// The completion handler type for the decorated function.
    /// - Parameter result: A `Result` containing either a `SerialStamped<Serial, Value>` on success or an `Error` on failure.
    typealias DecorateeCompletion = (Result<SerialStamped<Serial, Value>, Error>) -> Void
    
    /// The original decoratee function that takes a `Payload` and a completion handler.
    /// It may perform some asynchronous work and then call the completion handler.
    typealias Decoratee = (Payload, @escaping DecorateeCompletion) -> Void
    
    /// The completion handler type for caching operations.
    /// - Parameter result: A `Result` indicating success with `Void` or an `Error` on failure.
    typealias CacheCompletion = (Result<Void, Error>) -> Void
    
    /// The cache function that stores a `SerialStamped<Serial, Value>` and calls a completion handler.
    typealias Cache = (SerialStamped<Serial, Value>, @escaping CacheCompletion) -> Void
}

// MARK: - SerialStampedCachingDecorator Methods
public extension SerialStampedCachingDecorator {
    
    /// Allows the instance to be called as a function, applying the decorated behaviour.
    ///
    /// - Parameters:
    ///   - payload: A `Payload` to provide the serial.
    ///   - completion: A completion handler that returns the result of the decorated function.
    ///
    /// This method will fetch a response using the decoratee, and if the response's serial
    /// is different from the provided serial, it will be cached.
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
    ///   - payload: A `Payload` to provide the serial.
    ///   - completion: A completion handler that returns the result of the decorated function.
    ///
    /// This function first invokes the decoratee to fetch the result. If the result's serial is
    /// different from the provided serial, it will cache the result and then call the completion handler.
    /// If the serials are the same, it skips caching and simply calls the completion handler.
    func decorated(
        _ payload: Payload,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(payload) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(success):
                // Cache the response only if the serials are different
                if success.serial != payload.serial {
                    self.cache(success) { _ in completion(.success(success)) }
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}

public extension SerialStampedCachingDecorator {
    
    /// Allows the instance to be called with a `Serial` value.
    ///
    /// - Parameters:
    ///   - serial: A `Serial` value.
    ///   - completion: A completion handler that returns the result of the decorated function.
    func callAsFunction(
        _ serial: Serial?,
        completion: @escaping DecorateeCompletion
    ) {
        callAsFunction(.serial(serial), completion: completion)
    }
    
    /// Allows the instance to be called with a type conforming to `WithSerial`.
    ///
    /// - Parameters:
    ///   - withSerial: An instance conforming to `WithSerial<Serial>`.
    ///   - completion: A completion handler that returns the result of the decorated function.
    func callAsFunction<T: WithSerial>(
        _ withSerial: T,
        completion: @escaping DecorateeCompletion
    ) where T.Serial == Serial? {
        
        callAsFunction(.withSerial(withSerial), completion: completion)
    }
}
