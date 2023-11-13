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
    
    public typealias Map = (Success) -> NewSuccess
    public typealias MapError = (Failure) -> NewFailure
    
    private let _fetch: Fetch
    private let map: Map
    private let mapError: MapError
    
    public init(
        fetch: @escaping Fetch,
        map: @escaping Map,
        mapError: @escaping MapError
    ) {
        self._fetch = fetch
        self.map = map
        self.mapError = mapError
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
            
            completion(result.map(map).mapError(mapError))
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
