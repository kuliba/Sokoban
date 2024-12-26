//
//  CacheDecorator.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

/// A decorator that caches the responses of successful requests.
public final class CacheDecorator<Payload, Response, Failure>
where Failure: Error {
    
    private let decoratee: any Decoratee
    private let cache: Cache
    
    /// Initialises a new instance of `CacheDecorator`.
    ///
    /// - Parameters:
    ///   - decoratee: The loader to decorate.
    ///   - cache: A closure that caches the response and provides a completion handler.
    public init(
        decoratee: any Decoratee,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public typealias Decoratee = Loader<Payload, LoadResult>
    public typealias LoadResult = Result<Response, Failure>
    
    public typealias Cache = (Response, @escaping () -> Void) -> Void
}

extension CacheDecorator: Loader {
    
    /// Loads the specified payload, caching the response on success.
    ///
    /// - Parameters:
    ///   - payload: The payload to be loaded.
    ///   - completion: The completion handler to be called with the result of the loading operation.
    public func load(
        _ payload: Payload,
        _ completion: @escaping (LoadResult) -> Void
    ) {
        decoratee.load(payload) { [cache] in
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                cache(response) {
                    
                    completion(.success(response))
                }
            }
        }
    }
}
