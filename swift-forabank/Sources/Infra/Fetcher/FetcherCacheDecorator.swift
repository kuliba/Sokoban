//
//  FetcherCacheDecorator.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

public final class FetcherCacheDecorator<Payload, Success, Failure>
where Failure: Error {
    
    public typealias Decoratee = Fetcher<Payload, Success, Failure>
    public typealias Cache = (Success) -> Void
    
    private let decoratee: any Decoratee
    private let cache: Cache
    
    public init(
        decoratee: any Decoratee,
        cache: @escaping Cache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

extension FetcherCacheDecorator: Fetcher {
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        decoratee.fetch(payload) { [weak self] result in
            
            completion(result.map { success in
                
                self?.cache(success)
                return success
            })
        }
    }
}
