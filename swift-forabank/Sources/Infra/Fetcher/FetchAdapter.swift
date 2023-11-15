//
//  FetchAdapter.swift
//  
//
//  Created by Igor Malyarov on 13.11.2023.
//

public final class FetchAdapter<Payload, Success, NewSuccess, Failure, NewFailure>
where Failure: Error,
      NewFailure: Error {
    
    public typealias FetchResult = Result<Success, Failure>
    public typealias FetchCompletion = (FetchResult) -> Void
    public typealias Fetch = (Payload, @escaping FetchCompletion) -> Void
    
    public typealias MapResult = (Result<Success, Failure>) -> Result<NewSuccess, NewFailure>
    
    private let _fetch: Fetch
    private let mapResult: MapResult

    public init(
        fetch: @escaping Fetch,
        mapResult: @escaping MapResult
    ) {
        self._fetch = fetch
        self.mapResult = mapResult
    }
}

public extension FetchAdapter
where NewSuccess == Success,
      NewFailure == Failure {
    
    /// A wrapper for function.
    convenience init(fetch: @escaping Fetch) {
        
        self.init(fetch: fetch, mapResult: { $0 })
    }
}

public extension FetchAdapter {
    
    typealias Map = (Success) -> NewSuccess
    typealias MapError = (Failure) -> NewFailure
    
    convenience init(
        fetch: @escaping Fetch,
        map: @escaping Map,
        mapError: @escaping MapError
    ) {
        self.init(
            fetch: fetch,
            mapResult: { $0.map(map).mapError(mapError) }
        )
    }
}

extension FetchAdapter: Fetcher {
    
    public typealias NewFetchResult = Result<NewSuccess, NewFailure>
    public typealias NewFetchCompletion = (NewFetchResult) -> Void
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping NewFetchCompletion
    ) {
        _fetch(payload) { [weak self] result in
            
            guard let self else { return }
            
            completion(mapResult(result))
        }
    }
}

public extension FetchAdapter
where NewFailure == Failure {

    convenience init(
        fetch: @escaping Fetch,
        map: @escaping Map
    ) {
        self.init(fetch: fetch, map: map, mapError: { $0 })
    }
}

public extension FetchAdapter
where NewSuccess == Success {

    convenience init(
        fetch: @escaping Fetch,
        mapError: @escaping MapError
    ) {
        self.init(fetch: fetch, map: { $0 }, mapError: mapError)
    }
}

public extension FetchAdapter
where Payload == Void {
    
    convenience init(
        _ fetch: @escaping (@escaping FetchCompletion) -> Void,
        mapResult: @escaping MapResult
    ) {
        self.init(
            fetch: { _, completion in fetch(completion) },
            mapResult: mapResult
        )
    }
    
    convenience init(
        _ fetch: @escaping (@escaping FetchCompletion) -> Void,
        map: @escaping Map,
        mapError: @escaping MapError
    ) {
        self.init(
            fetch: { _, completion in fetch(completion) },
            map: map,
            mapError: mapError
        )
    }
    
    func fetch(completion: @escaping NewFetchCompletion) {
        
        _fetch(()) { [weak self] result in
            
            guard let self else { return }
            
            completion(mapResult(result))
        }
    }
}

public extension FetchAdapter
where Payload == Void,
      NewFailure == Failure {
    
    convenience init(
        _ fetch: @escaping (@escaping FetchCompletion) -> Void,
        map: @escaping Map
    ) {
        self.init(
            fetch: { _, completion in fetch(completion) },
            map: map,
            mapError: { $0 }
        )
    }
}
