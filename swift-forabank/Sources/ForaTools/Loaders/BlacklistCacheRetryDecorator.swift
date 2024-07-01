//
//  BlacklistCacheRetryDecorator.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import CombineSchedulers
import Foundation

public final class BlacklistCacheRetryDecorator<Payload, Response, Failure>
where Payload: Hashable,
      Failure: Error {
    
    private let cache: Cache
    private let decoratee: any Decoratee
    private let isBlacklisted: IsBlacklisted
    private let retryPolicy: RetryPolicy
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        cache: @escaping Cache,
        decoratee: any Decoratee,
        isBlacklisted: @escaping IsBlacklisted,
        retryPolicy: RetryPolicy,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.cache = cache
        self.decoratee = decoratee
        self.isBlacklisted = isBlacklisted
        self.retryPolicy = retryPolicy
        self.scheduler = scheduler
    }
    
    public typealias Cache = (Response, @escaping () -> Void) -> Void
    
    public typealias Decoratee = Loader<Payload, LoadResult>
    public typealias LoadResult = Result<Response, Failure>
    
    public typealias IsBlacklisted = (Payload, Int) -> Bool?
}

extension BlacklistCacheRetryDecorator: Loader {
    
    public typealias BlacklistedError = BlacklistDecorator<Payload, Response, Failure>.Error
    public typealias BlacklistedResult = Result<Response, BlacklistedError>
    public typealias BlacklistedCompletion = (BlacklistedResult) -> Void
    
    public func load(
        _ payload: Payload,
        _ completion: @escaping BlacklistedCompletion
    ) {
        let retryingLoader = RetryLoader(
            performer: decoratee,
            retryPolicy: retryPolicy,
            scheduler: scheduler
        )
        
        let blacklistFilter = BlacklistFilter(isBlacklisted: isBlacklisted)
        
        let decoratedRemote = BlacklistDecorator(
            decoratee: CacheDecorator(
                decoratee: retryingLoader,
                cache: cache
            ),
            isBlacklisted: blacklistFilter.isBlacklisted(_:)
        )
        
        decoratedRemote.load(payload) { completion($0); _ = decoratedRemote }
    }
}
