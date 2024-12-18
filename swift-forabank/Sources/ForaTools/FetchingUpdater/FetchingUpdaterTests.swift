//
//  FetchingUpdaterTests.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

public final class FetchingUpdater<Payload, T, V> {
    
    private let fetch: Fetch
    private let update: Update
    
    public init(
        fetch: @escaping Fetch,
        update: @escaping Update
    ) {
        self.fetch = fetch
        self.update = update
    }
    
    public typealias Fetch = (Payload, @escaping (T?) -> Void) -> Void
    public typealias Update = (T, @escaping (V) -> Void) -> Void
}

public extension FetchingUpdater {
    
    func load(
        payload: Payload,
        completion: @escaping (V?) -> Void
    ) {
        fetch(payload) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .none:
                completion(nil)
                
            case let .some(value):
                update(value, completion)
            }
        }
    }
}
