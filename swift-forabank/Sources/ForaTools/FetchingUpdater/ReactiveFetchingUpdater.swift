//
//  ReactiveFetchingUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public final class ReactiveFetchingUpdater<Payload, T, V> {
    
    private let fetcher: any Fetcher
    private let updater: any Updater
    
    private var cancellable: AnyCancellable?
    
    public init(
        fetcher: any Fetcher,
        updater: any Updater
    ) {
        self.fetcher = fetcher
        self.updater = updater
    }
    
    public typealias Fetcher = OptionalFetcher<Payload, T>
    
    public typealias Updater = ReactiveUpdater<T, V>
}

public extension ReactiveFetchingUpdater {
    
    func load(
        payload: Payload,
        completion: @escaping (V?) -> Void
    ) {
        cancellable = Future { [weak self] promise in
            
            guard let self else { return promise(.success(nil)) }
            
            fetcher.fetch(payload) { promise(.success($0)) }
        }
        .compactMap { $0 }
        .flatMap(updater.update)
        .sink(
            receiveCompletion: { _ in completion(nil) },
            receiveValue: completion
        )
    }
}
