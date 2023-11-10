//
//  FetcherDecorator.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

public final class FetcherDecorator<Payload, Success, Failure>
where Failure: Error {
    
    public typealias Decoratee = Fetcher<Payload, Success, Failure>
    public typealias Handle = () -> Void
    public typealias OnSuccess = (Success, @escaping Handle) -> Void
    public typealias OnFailure = (Failure, @escaping Handle) -> Void
    
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
            
            switch result {
            case let .failure(error):
                self?.onFailure(error) { completion(result) }
                
            case let .success(success):
                self?.onSuccess(success) { completion(result) }
            }
        }
    }
}

public extension FetcherDecorator {
    
    convenience init(
        decoratee: any Decoratee,
        onSuccess: @escaping OnSuccess
    ) {
        self.init(
            decoratee: decoratee,
            onSuccess: onSuccess,
            onFailure: { _, completion in completion() }
        )
    }
    
    convenience init(
        decoratee: any Decoratee,
        onFailure: @escaping OnFailure
    ) {
        self.init(
            decoratee: decoratee,
            onSuccess: { _, completion in completion() },
            onFailure: onFailure
        )
    }
}

public extension FetcherDecorator {
    
    typealias HandleSuccess = (Success) -> Void
    
    convenience init(
        decoratee: any Decoratee,
        handleSuccess: @escaping HandleSuccess
    ) {
        self.init(
            decoratee: decoratee,
            onSuccess: { success, completion in
                
                handleSuccess(success)
                completion()
            },
            onFailure: { _, completion in completion() }
        )
    }
    
    typealias HandleFailure = (Failure) -> Void
    
    convenience init(
        decoratee: any Decoratee,
        handleFailure: @escaping HandleFailure
    ) {
        self.init(
            decoratee: decoratee,
            onSuccess: { _, completion in completion() },
            onFailure: { failure, completion in
                
                handleFailure(failure)
                completion()
            }
        )
    }
}
