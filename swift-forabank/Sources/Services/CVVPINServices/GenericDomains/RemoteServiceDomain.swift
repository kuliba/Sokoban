//
//  RemoteServiceDomain.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

/// A namespace.
public enum RemoteServiceDomain<Payload, Success, Failure: Error> {}

public extension RemoteServiceDomain {
    
    typealias Result = Swift.Result<Success, Failure>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (Payload, @escaping Completion) -> Void
}

public typealias RemoteServiceDomainOf<Payload, Success> = RemoteServiceDomain<Payload, Success, Error>
