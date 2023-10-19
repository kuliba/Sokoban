//
//  Domain.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

public typealias DomainOf<Success> = Domain<Success, Error>

/// A namespace.
public enum Domain<Success, Failure: Error> {}
    
public extension Domain {
    
    typealias Result = Swift.Result<Success, Failure>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (@escaping Completion) -> Void
}
