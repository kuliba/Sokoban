//
//  Fetcher.swift
//  
//
//  Created by Igor Malyarov on 06.11.2023.
//

public protocol Fetcher<Payload, Success, Failure> {
    
    associatedtype Payload
    associatedtype Success
    associatedtype Failure: Error
    
    typealias FetchResult = Result<Success, Failure>
    typealias FetchCompletion = (FetchResult) -> Void
    
    func fetch(
        _ payload: Payload,
        completion: @escaping FetchCompletion
    )
}

public extension Fetcher where Payload == Void {
    
    func fetch(
        completion: @escaping FetchCompletion
    ) {
        fetch((), completion: completion)
    }
}
