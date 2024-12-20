//
//  BlacklistDecorator.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

/// A decorator that checks if a request is blacklisted before delegating to another loader.
public final class BlacklistDecorator<Request, Response, Failure>
where Failure: Error {
    
    private let decoratee: any Decoratee
    private let isBlacklisted: IsBlacklisted
    
    /// Initialises a new instance of `BlacklistDecorator`.
    ///
    /// - Parameters:
    ///   - decoratee: The loader to decorate.
    ///   - isBlacklisted: A closure that checks if a request is blacklisted.
    public init(
        decoratee: any Decoratee,
        isBlacklisted: @escaping IsBlacklisted
    ) {
        self.decoratee = decoratee
        self.isBlacklisted = isBlacklisted
    }
    
    public typealias Decoratee = Loader<Request, LoadResult>
    public typealias LoadResult = Result<Response, Failure>
    public typealias IsBlacklisted = (Request) -> Bool
    
    public enum Error: Swift.Error {
        
        case blacklistedError
        case loadFailure(Failure)
    }
}

extension BlacklistDecorator: Loader {
    
    /// Loads the specified request, checking if it is blacklisted before delegating to the decoratee.
    ///
    /// - Parameters:
    ///   - request: The request to be loaded.
    ///   - completion: The completion handler to be called with the result of the loading operation.
    public func load(
        _ request: Request,
        _ completion: @escaping (Result<Response, Error>) -> Void
    ) {
        if isBlacklisted(request) {
            completion(.failure(.blacklistedError))
        } else {
            decoratee.load(request) {
                
                switch $0 {
                case let .failure(error):
                    completion(.failure(.loadFailure(error)))
                    
                case let .success(response):
                    completion(.success(response))
                }
            }
        }
    }
}

extension BlacklistDecorator.Error: Equatable where Failure: Equatable {}
