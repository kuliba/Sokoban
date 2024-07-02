//
//  ResourceLoaderComposer.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import CombineSchedulers
import Foundation

public final class ResourceLoaderComposer<Payload, Response, Failure>
where Payload: Hashable,
      Failure: Error {
    
    private let cache: Cache
    private let localLoader: any LocalLoader
    private let remoteLoader: any RemoteLoader
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        cache: @escaping Cache,
        localLoader: any LocalLoader,
        remoteLoader: any RemoteLoader,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.cache = cache
        self.localLoader = localLoader
        self.remoteLoader = remoteLoader
        self.scheduler = scheduler
    }
    
    public typealias Cache = (Response, @escaping () -> Void) -> Void
    
    public typealias LocalLoader = Loader<Payload, Result<Response, Error>>
    public typealias RemoteLoader = Loader<Payload, LoadResult>
    public typealias LoadResult = Result<Response, Failure>
}

public extension ResourceLoaderComposer {
    
    typealias ComposedLoader = Loader<Payload, BlacklistedResult>
    typealias BlacklistedResult = Result<Response, BlacklistedError>
    typealias BlacklistedError = BlacklistDecorator<Payload, Response, Failure>.Error
    
    func compose(
        isBlacklisted: @escaping (Payload, Int) -> Bool,
        retryPolicy: RetryPolicy
    ) -> any ComposedLoader {
        
        let retryingRemoteLoader = RetryLoader(
            performer: remoteLoader,
            retryPolicy: retryPolicy,
            scheduler: scheduler
        )
        
        let blacklistFilter = BlacklistFilter(isBlacklisted: isBlacklisted)
        
        let decoratedRemote = BlacklistDecorator(
            decoratee: CacheDecorator(
                decoratee: retryingRemoteLoader,
                cache: cache
            ),
            isBlacklisted: blacklistFilter.isBlacklisted(_:)
        )
        
        return RequestBundler(
            performer: StrategyLoader(
                primary: localLoader,
                secondary: decoratedRemote
            )
        )
    }
}
