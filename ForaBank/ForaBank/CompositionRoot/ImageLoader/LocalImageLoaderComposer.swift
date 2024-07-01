//
//  LocalImageLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.07.2024.
//

import ForaTools
import SwiftUI

/// A composer responsible for creating an `ImageLoader` with local cache and logging functionalities.
final class LocalImageLoaderComposer {
    
    private let load: Load
    private let log: Log
    private let inMemoryStore: InMemoryStore
    
    /// Initialises the `LocalImageLoaderComposer` with the provided load and log closures.
    ///
    /// - Parameters:
    ///   - load: The load closure that performs the image loading from persistent storage.
    ///   - log: The log closure that handles logging events.
    init(
        load: @escaping Load,
        log: @escaping Log
    ) {
        self.load = load
        self.log = log
        self.inMemoryStore = .init()
    }
}

extension LocalImageLoaderComposer {
    
    /// Typealias for the load closure.
    ///
    /// The load closure takes a string identifier and a completion handler,
    /// and performs image loading from persistent storage.
    typealias Load = (String, @escaping (Result<Image, Error>) -> Void) -> Void
    
    /// Typealias for the log closure.
    ///
    /// The log closure takes a log level, a message, a static string (usually the file name),
    /// and a line number, and performs logging.
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> Void
    
    private typealias InMemoryStore = InMemoryValueStore<String, Image>
}

extension LocalImageLoaderComposer {
    
    /// Composes and returns an `ImageLoader` that uses in-memory and local caching strategies with logging.
    ///
    /// - Returns: A composed `ImageLoader` instance.
    ///
    /// The composed `ImageLoader` first attempts to load the image from an in-memory cache.
    /// If the image is not found in memory, it tries to load it from persistent storage.
    /// When loading from persistent storage, the in-memory store is updated with the loaded image.
    func compose() -> any ImageLoader {
        
        return StrategyLoader(
            primary: inMemoryLoggingLoader(),
            secondary: localLoggingLoader()
        )
    }
}

private extension LocalImageLoaderComposer {
    
    typealias LoadResult = Result<(String, Image), Error>
    typealias LoadCompletion = (LoadResult) -> Void
    
    func inMemoryLoggingLoader() -> any ImageLoader {
        
        return LoggingDecorator(
            decoratee: AnyLoader(loadFromMemory(_:_:)),
            log: log
        )
    }
    
    private func loadFromMemory(
        _ key: String,
        _ completion: @escaping LoadCompletion
    ) {
        inMemoryStore.retrieve(key: key) {
            
            completion($0.map { (key, $0) })
        }
    }
    
    func localLoggingLoader() -> any ImageLoader {
        
        return LoggingDecorator(
            decoratee: cachingLoader(),
            log: log
        )
    }
    
    private func cachingLoader() -> any ImageLoader {
        
        return CacheDecorator(
            decoratee: AnyLoader(loadFromPersistent),
            cache: loggingCache
        )
    }
    
    private func loadFromPersistent(
        key: String,
        completion: @escaping LoadCompletion
    ) {
        self.load(key) { completion($0.map { (key, $0) }) }
    }
    
    private func loggingCache(
        payload: (key: String, value: Image),
        completion: @escaping () -> Void
    ) {
        inMemoryStore.save(payload: payload) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(failure):
                log(.error, "\(String(describing: inMemoryStore)): Save failure: \(failure).", #file, #line)
                
            case .success:
                log(.info, "\(String(describing: inMemoryStore)): Save success.", #file, #line)
            }
            
            completion()
        }
    }
}
