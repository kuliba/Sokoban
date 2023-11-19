//
//  KeyLoadDomain.swift
//  
//
//  Created by Igor Malyarov on 17.08.2023.
//

public enum KeyLoadDomain<Payload, Key> {}

public extension KeyLoadDomain {
    
    typealias Result = Swift.Result<Key, Error>
    typealias Completion = (Result) -> Void
    typealias LoadKey = (Payload, @escaping Completion) -> Void
}
