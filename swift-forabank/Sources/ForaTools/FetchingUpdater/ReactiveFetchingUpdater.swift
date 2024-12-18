//
//  ReactiveFetchingUpdater.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

import Combine

public final class ReactiveFetchingUpdater<Payload, T, V> {
    
    private let fetch: Fetch
    private let update: Update
    
    private var cancellable: AnyCancellable?
    
    public init(
        fetch: @escaping Fetch,
        update: @escaping Update
    ) {
        self.fetch = fetch
        self.update = update
    }
    
    public typealias Fetch = (Payload, @escaping (T?) -> Void) -> Void
    public typealias Update = (T) -> AnyPublisher<V, Never>
}

public extension ReactiveFetchingUpdater {
    
    func load(
        payload: Payload,
        completion: @escaping (V?) -> Void
    ) {
        cancellable = Future { [weak self] promise in
            
            guard let self else { return promise(.success(nil)) }
            
            fetch(payload) { promise(.success($0)) }
        }
        .compactMap { $0 }
        .flatMap(update)
        .sink(
            receiveCompletion: { _ in completion(nil) },
            receiveValue: completion
        )
    }
}
