//
//  FetchDecorator.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

public final class FetchDecorator<Payload, Success, Failure>
where Failure: Error {
    
    public typealias FetchResult = Result<Success, Failure>
    public typealias FetchCompletion = (FetchResult) -> Void
    public typealias Fetch = (Payload, @escaping FetchCompletion) -> Void
    
    public typealias HandleResultCompletion = () -> Void
    public typealias HandleFetchResult = (FetchResult, @escaping HandleResultCompletion) -> Void
    
    private let _fetch: Fetch
    private let handleResult: HandleFetchResult
    
    public init(
        fetch: @escaping Fetch,
        handleResult: @escaping HandleFetchResult
    ) {
        self._fetch = fetch
        self.handleResult = handleResult
    }
}

extension FetchDecorator: Fetcher {
    
    public func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    ) {
        _fetch(payload) { [weak self] result in
            
            self?.handleResult(result) { completion(result) }
        }
    }
}

public extension FetchDecorator
where Payload == Void {
    
    convenience init(
        _ fetch: @escaping (@escaping FetchCompletion) -> Void,
        handleResult: @escaping HandleFetchResult
    ) {
        self.init(
            fetch: { _, completion in fetch(completion) },
            handleResult: handleResult
        )
    }
    
    func fetch(completion: @escaping FetchCompletion) {
        
        _fetch(()) { [weak self] result in
            
            self?.handleResult(result) { completion(result) }
        }
    }
}
