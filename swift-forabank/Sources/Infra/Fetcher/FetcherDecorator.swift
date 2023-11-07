//
//  FetcherDecorator.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

public final class FetcherDecorator<Payload, Success, Failure>
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

extension FetcherDecorator: Fetcher {
    
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
                    .mapError { failure in
                        
                        self?.handleFailure(failure)
                        return failure
                    }
            )
        }
    }
}

public extension FetcherDecorator {
    
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

