//
//  FetcherDecorator.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

public final class FetcherDecorator<Payload, Success, Failure>
where Failure: Error {
    
    public typealias Decoratee = Fetcher<Payload, Success, Failure>
    public typealias OnSuccess = (Success) -> Void
    public typealias OnFailure = (Failure) -> Void
    
    private let decoratee: any Decoratee
    private let onSuccess: OnSuccess
    private let onFailure: OnFailure
    
    public init(
        decoratee: any Decoratee,
        onSuccess: @escaping OnSuccess,
        onFailure: @escaping OnFailure
    ) {
        self.decoratee = decoratee
        self.onSuccess = onSuccess
        self.onFailure = onFailure
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
                        
                        self?.onSuccess(success)
                        return success
                    }
                    .mapError { failure in
                        
                        self?.onFailure(failure)
                        return failure
                    }
            )
        }
    }
}

public extension FetcherDecorator {
    
    convenience init(
        decoratee: any Decoratee,
        cache: @escaping OnSuccess
    ) {
        self.init(
            decoratee: decoratee,
            onSuccess: cache,
            onFailure: { _ in }
        )
    }
    
    convenience init(
        decoratee: any Decoratee,
        handleFailure: @escaping OnFailure
    ) {
        self.init(
            decoratee: decoratee,
            onSuccess: { _ in },
            onFailure: handleFailure
        )
    }
}
