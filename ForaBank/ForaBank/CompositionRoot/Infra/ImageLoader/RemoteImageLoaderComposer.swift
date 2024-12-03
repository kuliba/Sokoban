//
//  RemoteImageLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.07.2024.
//

import CombineSchedulers
import ForaTools
import Foundation
import SwiftUI

final class RemoteImageLoaderComposer {
    
    private let cache: Cache
    private let remoteLoader: any ImageLoader
    private let isBlacklisted: IsBlacklisted
    private let retryPolicy: RetryPolicy
    
    /// Initialises a new `RemoteImageLoaderComposer` with the given dependencies.
    ///
    /// - Parameters:
    ///   - cache: A closure that handles caching of images.
    ///   - remoteLoader: An instance of `ImageLoader` to load images remotely.
    ///   - isBlacklisted: A closure that determines if a given key is blacklisted.
    ///   - retryPolicy: An instance of `RetryPolicy` to handle retries on failures.
    init(
        cache: @escaping Cache,
        remoteLoader: any ImageLoader,
        isBlacklisted: @escaping IsBlacklisted,
        retryPolicy: RetryPolicy
    ) {
        self.cache = cache
        self.remoteLoader = remoteLoader
        self.isBlacklisted = isBlacklisted
        self.retryPolicy = retryPolicy
    }
}

extension RemoteImageLoaderComposer {
    
    typealias Cache = ((String, Image), @escaping () -> Void) -> Void
    typealias IsBlacklisted = (String, Int) -> Bool?
}

extension RemoteImageLoaderComposer {
    
    /// Composes an `ImageLoader` with additional functionalities like caching, blacklisting, and retry policy.
    ///
    /// - Parameter scheduler: The scheduler on which the loading operations are performed. Defaults to main queue.
    /// - Returns: An instance of `ImageLoader` with additional functionalities.
    func compose(
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> any ImageLoader {
        
        let decorated = BlacklistCacheRetryDecorator(
            cache: cache,
            decoratee: remoteLoader,
            isBlacklisted: isBlacklisted,
            retryPolicy: retryPolicy,
            scheduler: scheduler
        )
        
        return AnyLoader { key, completion in
            
            decorated.load(key) { result in
                
                completion(result.mapError { $0 })
            }
        }
    }
}

extension RemoteImageLoaderComposer {
    
    /// Convenience initialiser that uses default values for `isBlacklisted` and `retryPolicy`.
    ///
    /// - Parameters:
    ///   - cache: A closure that handles caching of images.
    ///   - remoteLoader: An instance of `ImageLoader` to load images remotely.
    convenience init(
        cache: @escaping Cache,
        remoteLoader: any ImageLoader
    ) {
        let isBlacklisted: IsBlacklisted = { _, attempt in attempt > 1 }
        
        self.init(
            cache: cache,
            remoteLoader: remoteLoader,
            isBlacklisted: isBlacklisted,
            retryPolicy: .singleRetryAfterOneSecond
        )
    }
}

private extension RetryPolicy {
    
    static let singleRetryAfterOneSecond: Self = .init(
        maxRetries: 1,
        strategy: .equal(interval: .seconds(1))
    )
}
