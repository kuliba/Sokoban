//
//  FetcherCacheDecorator.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

#warning("rename to `FetcherDecorator`")
public final class FetcherCacheDecorator<Payload, Success, Failure>
where Failure: Error {
    
    public typealias Decoratee = Fetcher<Payload, Success, Failure>
    public typealias HandleSuccess = (Success) -> Void
    public typealias HandleFailure = (Failure) -> Void
    
    private let decoratee: any Decoratee
    private let handleSuccess: HandleSuccess
    private let handleFailure: HandleFailure
    
    public init(
        decoratee: any Decoratee,
        handleSuccess: @escaping HandleSuccess,
        handleFailure: @escaping HandleFailure
    ) {
        self.decoratee = decoratee
        self.handleSuccess = handleSuccess
        self.handleFailure = handleFailure
    }
}

extension FetcherCacheDecorator: Fetcher {
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        decoratee.fetch(payload) { [weak self] result in
            
            completion(
                result
                    .map { success in
                        
                        self?.handleSuccess(success)
                        return success
                    }
            )
        }
    }
}

public extension FetcherCacheDecorator {
    
    convenience init(
        decoratee: any Decoratee,
        cache: @escaping HandleSuccess
    ) {
        self.init(
            decoratee: decoratee,
            handleSuccess: cache,
            handleFailure: { _ in }
        )
    }
}

