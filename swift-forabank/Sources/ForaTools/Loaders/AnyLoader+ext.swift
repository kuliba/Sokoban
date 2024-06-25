//
//  AnyLoader+ext.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

public extension AnyLoader {
    
    /// Initialises a new instance of `AnyLoader` by wrapping an existing loader.
    ///
    /// This initialiser provides a convenient way to create an `AnyLoader` from any existing loader that conforms to the `Loader` protocol.
    ///
    /// - Parameter loader: An existing loader that conforms to the `Loader` protocol.
    init(_ loader: any Loader<Payload, Response>) {
        
        self.init(loader.load(_:_:))
    }
    
    /// Creates a new instance of `AnyLoader` with the error type mapped using the provided closure.
    ///
    /// - Parameter mapError: A closure that maps the current error type to a new error type.
    /// - Returns: A new `AnyLoader` with the error type mapped.
    func mapError<Success, Failure, NewFailure>(
        _ mapError: @escaping (Failure) -> NewFailure
    ) -> AnyLoader<Payload, Result<Success, NewFailure>>
    where Response == Result<Success, Failure> {
        
        AnyLoader<Payload, Result<Success, NewFailure>> { payload, completion in
            
            self.load(payload) { result in
                switch result {
                case let .success(response):
                    completion(.success(response))
                    
                case let .failure(error):
                    completion(.failure(mapError(error)))
                }
            }
        }
    }
    
    /// Creates a new instance of `AnyLoader` that uses a blacklist decorator.
    ///
    /// This method wraps the current loader with a `BlacklistDecorator` that checks if a request is blacklisted using the provided closure.
    ///
    /// - Parameter isBlacklisted: A closure that determines whether a request should be blacklisted based on the request and the number of attempts.
    /// - Returns: A new `AnyLoader` with blacklist checking.
    func blacklisted<Success, Failure>(
        isBlacklisted: @escaping (Payload, Int) -> Bool
    ) -> AnyLoader<Payload, Result<Success, BlacklistDecorator<Payload, Success, Failure>.Error>>
    where Response == Result<Success, Failure>, Payload: Hashable {
        
        let blacklistFilter = BlacklistFilter(isBlacklisted: isBlacklisted)
        let blacklistDecorator = BlacklistDecorator(
            decoratee: self,
            isBlacklisted: blacklistFilter.isBlacklisted(_:)
        )
        
        return .init(blacklistDecorator)
    }
}
